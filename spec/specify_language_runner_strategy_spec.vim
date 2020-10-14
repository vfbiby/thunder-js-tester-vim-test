source spec/support/helpers.vim

describe "Language runner strategy"

  before
    cd spec/fixtures/js_multiple

    let g:test#javascript#runner = 'mocha'
    function! TermStrategy(cmd)
        let g:test#test_result = 'test#strategy worked!'
    endfunction

    function! JsTermStrategy(cmd)
        let g:test#test_result = 'MochaServer#strategy worked!'
    endfunction
  end

  after
    unlet g:test#test_result
    call Teardown()
    cd -
  end

  it "can be specified and work fine"
    let g:test#custom_strategies = {'jsTermOpen': function('JsTermStrategy')}
    let g:test#javascript#mocha#strategy = 'jsTermOpen'

    view +1 __tests__/normal-test.js
    TestNearest

    Expect g:test#test_result == 'MochaServer#strategy worked!'
    unlet g:test#javascript#mocha#strategy 
  end

  it 'if not be specified, test#strategy will work'
    let g:test#custom_strategies = {'termOpen': function('TermStrategy')}
    let g:test#strategy = 'termOpen'

    view +1 __tests__/normal-test.js
    TestNearest

    Expect g:test#test_result == 'test#strategy worked!'
  end

  it "has higher priority then test#strategy"
    let g:test#custom_strategies = {'termOpen': function('TermStrategy'), 'jsTermOpen': function('JsTermStrategy')}
    let g:test#javascript#mocha#strategy = 'jsTermOpen'

    view +1 __tests__/normal-test.js
    TestNearest
    Expect g:test#test_result == 'MochaServer#strategy worked!'

    let g:test#strategy = 'termOpen'
    TestNearest
    Expect g:test#test_result == 'MochaServer#strategy worked!'
    unlet g:test#javascript#mocha#strategy 
  end

  it 'will work with TestLast'
    let g:test#custom_strategies = {'termOpen': function('TermStrategy'), 'jsTermOpen': function('JsTermStrategy')}
    let g:test#javascript#mocha#strategy = 'jsTermOpen'
    let g:test#strategy = 'termOpen'

    view +1 __tests__/normal-test.js
    TestNearest
    Expect g:test#test_result == 'MochaServer#strategy worked!'

    let g:test#test_result = ''

    TestLast
    Expect g:test#test_result == 'MochaServer#strategy worked!'
    Expect g:test#last_strategy == 'jsTermOpen'
    unlet g:test#javascript#mocha#strategy 
  end
end
