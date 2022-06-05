child_process = require('child_process')
module.exports = (robot) ->

  robot.respond /ts (.*)/i, (msg) ->

    room = msg.message.room
    instance = msg.match[1]

    msg.send({
    attachments: [{
        title: 'Checking server status',
        }],
    })

    child_process.exec 'ping -w2 '+instance, (error, stdout, stderr) ->
      msg.send("Ping result", stdout)

    child_process.exec 'dig +noall +answer @'+instance+' google.com', (error, stdout, stderr) ->
      msg.send("Dig result for "+instance, stdout)

    child_process.exec 'ssh '+instance+" 'uptime'", (error, stdout, stderr) ->
      msg.send("Uptime result", stdout)
