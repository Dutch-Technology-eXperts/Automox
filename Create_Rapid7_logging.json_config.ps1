# Evaluation code

exit 1

# Remediation Code

if ($configcheck -eq "True")
{Write-Output "logging.json already exists"
exit 0}

New-Item "C:\Program Files\Rapid7\Insight Agent\components\insight_agent\common\config\logging.json"

Set-Content -Path "C:\Program Files\Rapid7\Insight Agent\components\insight_agent\common\config\logging.json" -Value '{ 
    "config": {
    "name": "insight agent windows",
    "endpoint": "eu.data.logs.insight.rapid7.com",
    "region": "eu",
    "api-key": "PLACE YOUR API KEY HERE",
    "state-file": "C:\\Program Files\\Rapid7\\Insight Agent\\components\\insight_agent\\common\\state.file",
    "formatter" : "plain",
    "windows-eventlog": {
      "enabled": true,
      "destination": "Windows Event Logs/Endpoints"
          },
    "metrics": {
      "destination": "System Metrics/Endpoints",
      "metrics-cpu": "system",
      "metrics-disk": "sum sda4 sda5",
      "metrics-interval": "60s",
      "metrics-mem": "system",
      "metrics-net": "sum eth0",
      "metrics-space": "/",
      "metrics-swap": "system",
      "metrics-vcpu": "core",
      "system-stat-enabled": true
    },
		     "logs": []
  }
 }'

  Restart-Service -Name "ir_agent"
