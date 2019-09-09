defmodule Mix.Tasks.Lambda.Build do
  use Mix.Task

  @shortdoc "Uses Docker to build a release zip for deployment to Lambda"

  @moduledoc """
  Builds tagged Docker images for apps in your umbrella.
  ```
  mix lambda.docker_build
  ```

  ## Examples

  ```
    ❯ mix lambda.docker_build
    Building elixir_lambda_example version 0.1.0
    . . .
    ---> bfd1abec1a2b
    Successfully built bfd1abec1a2b
    Successfully tagged elixir_lambda_example_0.1.0:latest
    output: /workspace/lambda.zip
    elixir_lambda_example_0.1.0
    Lambda release built!!
    artifact: _build/dev/rel/elixir_lambda_example/elixir_lambda_example_0.1.0_lambda.zip
  ```
  """

  def run(_args) do
    app =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> to_string
    version = Mix.Project.config()[:version]
    env = Mix.env()
    dockerfile = Path.expand("#{__DIR__}/../../../priv/docker/Dockerfile.build")
    release_dir = "_build/#{env}/rel/#{app}"

    Mix.shell().info("Building #{app} version #{version}")
    File.mkdir_p(release_dir)

    commands = [
      "docker rm #{app}_#{version} || true",
      "docker build --build-arg MIX_ENV=#{env} -t #{app}_#{version} -f #{dockerfile} .",
      "docker run --name #{app}_#{version} #{app}_#{version}",
      "docker cp #{app}_#{version}:/workspace/lambda.zip #{release_dir}/lambda.#{env}.zip",
      "docker rm #{app}_#{version}"
    ]

    Enum.each(commands, fn command ->
      Mix.shell().cmd(command)
      |> case do
           0 ->
             :ok

           status ->
             Mix.shell().error("Build failed")
             Mix.raise("Exit status: #{inspect(status)}")
         end
    end)

    Mix.shell().info("Lambda release built!!")
    Mix.shell().info("artifact: #{release_dir}/lambda.#{env}.zip")
  end
end
