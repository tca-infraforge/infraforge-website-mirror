exports.handler = async (event) => {
  const body = JSON.parse(event.body);
  const serverSecret = process.env.APP_API_SECRET_KEY;
  const incomingSecret = event.headers['x-api-key'];

  if (!incomingSecret || incomingSecret !== serverSecret) {
    return {
      statusCode: 403,
      body: JSON.stringify({ message: "Forbidden: invalid API secret" }),
    };
  }

  console.log("Verified form:", body);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Form received", name: body.name }),
  };
};
