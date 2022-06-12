child_process = require 'child_process'
request = require 'request'
module.exports = (robot) ->

  robot.catchAll (msg) ->

    instance = /FIRING.*\((.*?)\s/.exec(msg.message)[1]
    instance_short = /(.*?)\./.exec(instance)[1]

    green = "#36a64f"
    red = "#E91919"
    blue = "#2719E9"
    grey = "#838386"
    yellow = "#DBE824"
    mrkdwn = "```"

    random_name = (Math.random() + 1).toString(36).substring(7)
    random_robot = "https://robohash.org/"+random_name

    prometheus_url = "http://localhost:9090/api/v1/query?query="
    promql_uptime = "time%28%29+-+node_boot_time_seconds%7Binstance%3D%7E%22" + instance_short + ".%2A%22%7D"
    uptime_prometheus = prometheus_url + promql_uptime


    setAttachments =(PingResults, DigResults, UptimeResult) ->
      formated_ping_results = mrkdwn + PingResults + mrkdwn
      formated_dig_results = mrkdwn + DigResults + mrkdwn
      formated_uptime_result = mrkdwn + UptimeResult + mrkdwn
      attachment = {
      attachments: [{
          mrkdwn_in: ["text","value"],
          color: yellow,
          title: "Auto troubleshoot",
          text: "Server name: "+instance,
          thumb_url: random_robot
          fields: [
              {
               title: "Uptime result",
               value: formated_uptime_result,
               short: false
              },
              {
               title: "Ping results",
               value: formated_ping_results,
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
        resp = ""
        request.get {uri:uptime_prometheus, json : true}, (err, r, body) ->
          resp = body
          if resp.data.result[0] != undefined
            raw_seconds = resp.data.result[0].value[1]
            child_process.exec 'eval \"echo $(date -ud \"@' + raw_seconds + '\" +\'$((%s/3600/24)) days %H hours %M minutes %S seconds\')\"', (error, stdout, stderr) ->
              UptimeResult = stdout || stderr || error
              msg.send(setAttachments PingResults, DigResults, UptimeResult)
          else
            UptimeResult = "Not found"
            msg.send(setAttachments PingResults, DigResults, UptimeResult)
