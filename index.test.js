const index = require('./index');

test('Bryan is in the body', async () => {
  const resp = await index.hello();
  expect(resp.body).toMatch(/Brian/);
});
