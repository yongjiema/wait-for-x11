# shellcheck shell=sh

Describe 'wait-for-x11'
  Describe 'help & version'
    It 'should show help'
      When run script wait-for-x11 --help
      The status should be success
      The stdout should include 'help'
    End

    It 'should show version'
      When run script wait-for-x11 --version
      The status should be success
      The stdout should match pattern 'v*.*.*'
    End
  End

  Describe 'Check dependencies'
    Mock command
      exit 1
    End

    It 'should throw xdpyinfo is required'
      When run script wait-for-x11
      The status should be failure
      The stderr should eq 'Error: xdpyinfo is required.'
    End
  End

  Describe 'Parse arguments'
    Mock xdpyinfo
      exit 0
    End

    It 'should throw the unknown option error'
      When run script wait-for-x11 --non-existent
      The status should be failure
      The stderr should eq 'Error: unknown option: --non-existent'
    End

    It 'should accept a double dash before the command argument'
      When run script wait-for-x11 --display :0.0 --
      The status should be success
    End
  End

  Describe 'Check the required user input'
    Mock xdpyinfo
      exit 0
    End

    It 'should throw the X11 server display is not given error'
      When run script wait-for-x11
      The status should be failure
      The stderr should eq 'Error: the X11 server display is not given.'
    End

    It 'should be able to get the X11 server display is not given from environment variables'
      export DISPLAY=:0.0
      When run script wait-for-x11
      The status should be success
    End

    It 'should be able to get the X11 server display is not given from arguments'
      When run script wait-for-x11 --display :0.0
      The status should be success
    End
  End

  Describe 'Check retries'
    Mock xdpyinfo
      exit 1
    End

    time_elapsed_range() (
      start_time="${1:?}"
      end_time="${2:?}"
      from="${3:?}"
      to="${4:?}"

      time_elapsed="$((end_time - start_time))"
      [ "${time_elapsed}" -ge "${from}" ] && [ "${time_elapsed}" -le "${to}" ]
    )

    It 'should wait about 10 seconds by default'
      start_time="$(date +%s)"
      When run script wait-for-x11 --display :0.0
      end_time="$(date +%s)"
      The status should be failure
      The stderr should eq 'Error: exceeded maximum number of retries.'
      Assert time_elapsed_range "${start_time}" "${end_time}" 10 13
    End

    It 'should wait about 1 seconds'
      start_time="$(date +%s)"
      When run script wait-for-x11 --display :0.0 --max-retries 1
      end_time="$(date +%s)"
      The status should be failure
      The stderr should eq 'Error: exceeded maximum number of retries.'
      Assert time_elapsed_range "${start_time}" "${end_time}" 1 4
    End

    It 'should wait about 5 seconds'
      start_time="$(date +%s)"
      When run script wait-for-x11 --display :0.0 --retry-interval 0.5
      end_time="$(date +%s)"
      The status should be failure
      The stderr should eq 'Error: exceeded maximum number of retries.'
      Assert time_elapsed_range "${start_time}" "${end_time}" 5 8
    End
  End

  Describe 'When the X11 server is ready'
    Mock xdpyinfo
      now="$(date +%s)"
      if [ "$((now % 3))" -ne 0 ]; then
        exit 1
      fi
    End

    It 'should just wait util the X11 server to be ready'
      When run script wait-for-x11 --display :0.0
      The status should be success
      The stdout should eq ''
    End

    It 'should wait and then run the provided comamnd with arguments util the X11 server to be ready'
      When run script wait-for-x11 --display :0.0 printf 'OUTPUT\n'
      The status should be success
      The stdout should eq 'OUTPUT'
    End
  End
End
