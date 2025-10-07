const request = require('supertest');
const app = require('../../src/index');

describe('Health Check Endpoint', () => {
  it('should return 200 OK', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
  });

  it('should return healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.body.status).toBe('healthy');
  });

  it('should include timestamp', async () => {
    const response = await request(app).get('/health');
    expect(response.body.timestamp).toBeDefined();
  });
});