
# test/scv.coffee - Test the main SCV core engine.
do ->

  base = if process.env.SCV_COVER then '../src-cov' else '../src'

  describe 'test', ->
    it 'should passes', ->
      require "#{base}/scv"

