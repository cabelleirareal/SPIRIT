/**
 * SPIRIT Gateway - OpenClaw-based
 * Main entry point
 */

const WebSocket = require('ws');
const express = require('express');
const { createServer } = require('http');
const Redis = require('ioredis');

// Config
const PORT = process.env.PORT || 18789;
const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';

// Initialize Express
const app = express();
const server = createServer(app);

// Initialize Redis
const redis = new Redis(REDIS_URL);

// Initialize WebSocket Server
const wss = new WebSocket.Server({ server });

// Track connections
const connections = new Map();

// WebSocket connection handler
wss.on('connection', (ws, req) => {
  const clientId = generateId();
  console.log(`[Gateway] New connection: ${clientId}`);

  connections.set(clientId, {
    ws,
    authenticated: false,
    channels: [],
    metadata: {}
  });

  // Handle messages
  ws.on('message', async (data) => {
    try {
      const message = JSON.parse(data);
      await handleMessage(clientId, message);
    } catch (error) {
      console.error(`[Gateway] Message error:`, error);
      ws.send(JSON.stringify({
        type: 'error',
        error: error.message
      }));
    }
  });

  // Handle disconnect
  ws.on('close', () => {
    console.log(`[Gateway] Disconnected: ${clientId}`);
    connections.delete(clientId);
  });

  // Send welcome
  ws.send(JSON.stringify({
    type: 'hello',
    clientId,
    timestamp: Date.now()
  }));
});

// Message router
async function handleMessage(clientId, message) {
  const connection = connections.get(clientId);
  if (!connection) return;

  console.log(`[Gateway] Message from ${clientId}:`, message.type);

  switch (message.type) {
    case 'connect':
      await handleConnect(clientId, message);
      break;
    
    case 'chat':
      await handleChat(clientId, message);
      break;
    
    case 'agent':
      await handleAgent(clientId, message);
      break;
    
    default:
      connection.ws.send(JSON.stringify({
        type: 'error',
        error: `Unknown message type: ${message.type}`
      }));
  }
}

// Handle connect
async function handleConnect(clientId, message) {
  const connection = connections.get(clientId);
  
  // TODO: Implement device pairing
  connection.authenticated = true;
  connection.metadata = message.metadata || {};
  
  connection.ws.send(JSON.stringify({
    type: 'connected',
    status: 'ok'
  }));
  
  console.log(`[Gateway] Client ${clientId} connected`);
}

// Handle chat message
async function handleChat(clientId, message) {
  const connection = connections.get(clientId);
  
  // Forward to agent via Redis
  await redis.publish('agent:requests', JSON.stringify({
    clientId,
    type: 'chat',
    text: message.payload.text,
    timestamp: Date.now()
  }));
  
  // Acknowledge
  connection.ws.send(JSON.stringify({
    type: 'ack',
    messageId: message.id
  }));
}

// Handle agent response
async function handleAgent(clientId, message) {
  const connection = connections.get(clientId);
  
  connection.ws.send(JSON.stringify({
    type: 'agent',
    payload: message.payload
  }));
}

// Subscribe to agent responses
redis.subscribe('agent:responses', (err, count) => {
  if (err) {
    console.error('[Gateway] Redis subscribe error:', err);
  } else {
    console.log(`[Gateway] Subscribed to ${count} channels`);
  }
});

redis.on('message', (channel, message) => {
  if (channel === 'agent:responses') {
    try {
      const data = JSON.parse(message);
      const connection = connections.get(data.clientId);
      
      if (connection) {
        connection.ws.send(JSON.stringify({
          type: 'agent',
          payload: data.response
        }));
      }
    } catch (error) {
      console.error('[Gateway] Redis message error:', error);
    }
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    connections: connections.size,
    timestamp: Date.now()
  });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.json({
    connections: connections.size,
    authenticated: Array.from(connections.values())
      .filter(c => c.authenticated).length,
    uptime: process.uptime()
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`[Gateway] SPIRIT Gateway running on port ${PORT}`);
  console.log(`[Gateway] WebSocket: ws://localhost:${PORT}`);
  console.log(`[Gateway] Health: http://localhost:${PORT}/health`);
});

// Utility
function generateId() {
  return Math.random().toString(36).substring(2, 15);
}

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[Gateway] Shutting down...');
  wss.close(() => {
    redis.quit();
    server.close(() => {
      console.log('[Gateway] Shutdown complete');
      process.exit(0);
    });
  });
});
