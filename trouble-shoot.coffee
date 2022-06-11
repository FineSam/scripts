child_process = require('child_process')
module.exports = (robot) ->

  robot.catchAll (msg) ->

    r = new RegExp "ts (.*)", "i"
    instance = msg.message.text.match(r)[1]

    green = "#36a64f"
    red = "#E91919"
    blue = "#2719E9"
    grey = "#838386"
    yellow = "#DBE824"
    mrkdwn = "```"

    random_name = (Math.random() + 1).toString(36).substring(7)
    random_robot = "https://robohash.org/"+random_name

    setAttachments =(PingResults, DigResults) ->
      formated_ping_results = mrkdwn + PingResults + mrkdwn
      formated_dig_results = mrkdwn + DigResults + mrkdwn
      attachment = {
      attachments: [{
          mrkdwn_in: ["text","value"],
          color: yellow,
          title: "Auto troubleshoot",
          text: "Server name: "+instance,
          thumb_url: random_robot
          fields: [
              {
               title: "Ping results",
               value: formated_ping_results,
               short: false
              },
              {
               value: "---",
               short: false
              },
              {
               title: "Dig results",
               value: formated_dig_results,
               short: false
              }
          ],
          footer: "footer",
          footer_icon: "https://platform.slack-edge.com/img/default_application_icon.png",
      }]
      }

    child_process.exec 'ping -w2 '+instance, (error, stdout, stderr) ->
      PingResults = stdout || stderr || error
      child_process.exec 'dig @'+instance+' google.com', (error, stdout, stderr) ->
        DigResults = stdout || stderr || error
        msg.send(setAttachments PingResults, DigResults)
