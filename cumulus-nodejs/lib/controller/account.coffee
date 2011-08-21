module.exports =
  class Account
    create: (request, response) =>
      response.send "hello world"

    show: (request, response) =>
      response.send "hello world"
