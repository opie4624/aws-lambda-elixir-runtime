# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

defmodule Mix.Tasks.Lambda.GenLambdaRelease do
  @moduledoc """
  Generate a distillery release configuration file for lambda release builds.
  """

  use Mix.Task

  @shortdoc "Generate a release for AWS Lambda"
  def run(_) do
    name =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> to_string

    Mix.Generator.create_file("config/releases.exs", releases_exs(name))
    Mix.Generator.create_file("rel/env.sh.eex", env_sh())
    Mix.Generator.create_file("rel/vm.args.eex", vm_args())
  end

  defp releases_exs(app) do
    """
    # This file is responsible for runtime configuration
    # of your application and its dependencies
    import Config

    # You can configure your application as:
    #
    #     config :#{app}, :secret_key, System.fetch_env!("MY_APP_SECRET_KEY")
    #
    # and access this configuration in your application as:
    #
    #     Application.get_env(:#{app}, :key)
    #
    # You can also configure a third-party app:
    #
    #     config :logger, level: :info
    #
    """
  end

  defp env_sh do
    """
    #!/bin/sh

    # Sets and enables heart (recommended only in daemon mode)
    # case $RELEASE_COMMAND in
    #   daemon*)
    #     HEART_COMMAND="$RELEASE_ROOT/bin/$RELEASE_NAME $RELEASE_COMMAND"
    #     export HEART_COMMAND
    #     export ELIXIR_ERL_OPTIONS="-heart"
    #     ;;
    #   *)
    #     ;;
    # esac

    # Set the release to work across nodes. If using the long name format like
    # the one below (my_app@127.0.0.1), you need to also uncomment the
    # RELEASE_DISTRIBUTION variable below.
    # export RELEASE_DISTRIBUTION=name
    # export RELEASE_NODE=<%= @release.name %>@127.0.0.1

    export RELEASE_TMP="/tmp/elixir_release/${RELEASE_NAME}_${RELEASE_VERSION}"
    """
  end

  defp vm_args do
    """
    ## Customize flags given to the VM: http://erlang.org/doc/man/erl.html
    ## -mode/-name/-sname/-setcookie are configured via env vars, do not set them here

    ## Number of dirty schedulers doing IO work (file, sockets, etc)
    ##+SDio 5

    ## Increase number of concurrent ports/sockets
    ##+Q 65536

    ## Tweak GC to run more often
    ##-env ERL_FULLSWEEP_AFTER 10

    -start_epmd false -epmd_module Elixir.EPMD.StubClient
    """
  end
end
