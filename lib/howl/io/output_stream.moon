-- Copyright 2014 Nils Nordman <nino at nordman.org>
-- License: MIT (see LICENSE)

dispatch = howl.dispatch
{:UnixOutputStream} = require 'ljglibs.gio'
{:PropertyObject} = howl.aux.moon

class OutputStream extends PropertyObject
  new: (fd) =>
    @stream = UnixOutputStream fd
    super!

  @property is_closed: get: => @stream.is_closed

  write: (contents) =>
    handle = dispatch.park 'output-stream-write'

    @stream\write_async contents, nil, (status, ret, err_code) ->
      if status
        dispatch.resume handle, ret
      else
        dispatch.resume_with_error handle, "#{ret} (#{err_code})"

    dispatch.wait handle

  close: =>
    handle = dispatch.park 'output-stream-close'

    @stream\close_async (status, ret, err_code) ->
      if status
        dispatch.resume handle
      else
        dispatch.resume_with_error handle, "#{ret} (#{err_code})"

    dispatch.wait handle