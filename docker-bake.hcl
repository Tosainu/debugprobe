group "default" {
  targets = ["debugprobe"]
}

target "debugprobe" {
  dockerfile = "Dockerfile"
  target = "debugprobe"
  output = [{ type = "local", dest = "./build" }]
}
