integrationId = local('cat .integration-id | tr -d \'\n\' ')
local('kubectl create namespace snyk-monitor 2> /dev/null || echo \'Cluster already exists\' ')
local('kubectl create secret generic snyk-monitor -n snyk-monitor --from-literal=dockercfg.json={} --from-literal=integrationId=%s 2> /dev/null || echo \'Secret already exists\' ' % integrationId)

docker_build("snyk/kubernetes-monitor", ".",
  live_update=[
    fall_back_on(["package.json", "package-lock.json"]),
    sync('.', '/srv/app'),
  ],
  entrypoint="bin/start-tilt"
)

allow_k8s_contexts(['minikube', 'kubernetes-admin@kind'])
# print(local('cd kustomize/ && helm install snyk-monitor ../snyk-monitor --post-renderer ./kustomize --debug --dry-run -n snyk-monitor && cd ..'))
yaml = helm(
  'snyk-monitor',
  namespace='snyk-monitor',
  )
k8s_yaml(yaml)
k8s_resource('snyk-monitor', port_forwards='9229:9229')

# vscode config:
#    {
#      "type": "node",
#      "request": "attach",
#      "name": "Attach to Remote",
#      "address": "127.0.0.1",
#      "port": 9229,
#      "localRoot": "${workspaceFolder}",
#      "remoteRoot": "/srv/app"
#    }
