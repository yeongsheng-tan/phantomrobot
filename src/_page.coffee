class Page

    "Page should contain": (params, respond) ->
        needle = params[1][0]

        page_contains = (needle) ->
            queryAll(document, needle).length > 0\
                or document.body.innerText.indexOf(needle) > -1

        if @page.eval page_contains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains": (params, respond) ->
        @["Page should contain"](params, respond)

    "Element should contain": (params, respond) ->
        element = params[1][0]
        content = params[1][1]

        element_contains = (element, content) ->
            results = queryAll(document, element)
            for result in results
                if queryAll(result, content).length > 0\
                    or result.innerText.indexOf(content) > -1
                        return true
            false

        if @page.eval element_contains, element, content
            respond status: "PASS"
        else
            respond status: "FAIL",\
                    error: "Element '#{element}' did not contain '#{content}'."

    "Element text should be": (params, respond) ->
        element = params[1][0]
        text = params[1][1]

        element_text = (element, content) ->
            if /css=(.*)/.test element
                query = element.match(/css=(.*)/)[1]
                results = document.querySelectorAll(query)
                elem = results.length and results[0] or null
            else
                elem = document.getElementById(element)
            elem and elem.text or ""

        found_text = @page.eval element_text, element, text
        if found_text == text
            respond status: "PASS"
        else
            respond status: "FAIL",\
                    error: "Element '#{element}' had text '#{found_text}'."

    "Page should contain element": (params, respond) ->
        needle = params[1][0]

        page_contains = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                document.querySelectorAll(query).length > 0
            else
                document.getElementById(needle) and true or false

        if @page.eval page_contains, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page did not contain '#{needle}'."

    "Wait until page contains element": (params, respond) ->
        @["Page should contain element"](params, respond)

    "Page should not contain element": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page did contain '#{needle}'.",
            else
                respond status: "PASS"

    "Element should be visible": (params, respond) ->
        needle = params[1][0]

        visible_element_found = (needle) ->
            if /css=(.*)/.test needle
                query = needle.match(/css=(.*)/)[1]
                for element in document.querySelectorAll query
                    if element.offsetWidth > 0 and element.offsetHeight > 0
                        return true
                return false
            else
                elem = document.getElementById needle
                elem and elem.offsetWidth > 0 and elem.offsetHeight > 0

        if @page.eval visible_element_found, needle
            respond status: "PASS"
        else
            respond status: "FAIL", error: "Page had no visible '#{needle}'.",

    "Element should not be visible": (params, respond) ->
        needle = params[1][0]
        @["Element should be visible"] params, (response) ->
            if response?.status == "PASS"
                respond status: "FAIL", error: "Page had visible '#{needle}'.",
            else
                respond status: "PASS"

    "XPath should match X times": (params, respond) ->
        xpath = params[1][0]
        times = parseInt params[1][1], 10

        # Evaluate an XPath expression aExpression against a given DOM node
        # or Document object (aNode), returning the results as an array
        # thanks wanderingstan at morethanwarm dot mail dot com for the
        # initial work. https://developer.mozilla.org/en/Using_XPath
        xpath_match_length = (expr) ->
            xpe = do new XPathEvaluator
            nsResolver = xpe.createNSResolver document
            result = xpe.evaluate expr, document, nsResolver, 0, null
            [res for res in result.iterateNext()].length or 0

        length = @page.eval xpath_match_length, xpath
        if length == times
            respond status: "PASS"
        else
            respond status: "FAIL",\
                    error: "XPath '#{xpath}' matched only '#{length}' times.",
