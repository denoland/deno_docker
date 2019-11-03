export async function handler(event) {
  const body = { hello: "deno" };
  return {
    statusCode: 200,
    body: JSON.stringify(body)
  };
}
