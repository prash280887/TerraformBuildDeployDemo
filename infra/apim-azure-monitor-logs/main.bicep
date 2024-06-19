param apimName string

resource loggerAzureMonitor 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  name: '${apimName}/azuremonitor'
  properties: {
    loggerType: 'azureMonitor'
    isBuffered: true
  }
}

resource diagnosticsAzureMonitor 'Microsoft.ApiManagement/service/diagnostics@2023-03-01-preview' = {
  name: '${apimName}/azuremonitor'
  properties: {
    verbosity: 'information'
    logClientIp: true
    loggerId: loggerAzureMonitor.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 8192
        }
      }
      response: {
        headers: []
        body: {
          bytes: 8192
        }
      }
    }
  }
}
