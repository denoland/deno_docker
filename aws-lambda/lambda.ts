export async function handler(event) {
  return {
    statusCode: 200,
    body: `Welcome to deno ${Deno.version.deno} 🦕`
  };
}
