REQUEST_CLASSES = {
  get: {
    'method' => Net::HTTP::Get,
    'code' => 200,
    'message' => 'OK'
  },
  post: {
    'method' => Net::HTTP::Post,
    'code' => 201,
    'message' => 'Created'
  },
  patch: {
    'method' => Net::HTTP::Patch,
    'code' => 200,
    'message' => 'OK'
  },
  delete: {
    'method' => Net::HTTP::Delete,
    'code' => 204,
    'message' => 'No Content'
  }
}.freeze
