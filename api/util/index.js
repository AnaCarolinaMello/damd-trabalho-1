export function return200(response, res) {
  if (response && response.code == 400 && response.errors) {
    res.status(400).send(response);
  } else {
    res.status(200).send(response);
  }
}

export function return500(response, req, res) {
  const error = {
    message: response.message,
    stack: response.stack,
    date: new Date(),
    body: req.body,
    url: req.url,
    params: req.params,
    headers: req.headers,
  };
  res.status(500).send({ message: error.message });
}

export function return403(res) {
  res.status(403).send("Unauthorized");
}

export function return404(res, message) {
  res.status(404).send({
    error: "Not Found",
    message: message || "Resource not found",
  });
}

export function return503(res, message) {
  res.status(503).send({
    error: "Service Unavailable",
    message: message || "Service unavailable",
  });
}

export function return400(res, message) {
  res.status(400).send({ 
    error: "Bad Request", 
    message: message || "Invalid request parameters" 
  });
}
