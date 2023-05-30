classdef RegexTest < matlab.unittest.TestCase
    properties(Access=public)
        regexFilter;
    end

    properties(TestParameter)
        allMatchActions={Log4M.FilterAction.ACCEPT,Log4M.FilterAction.NEUTRAL,Log4M.FilterAction.DENY};
        allMismatchActions={Log4M.FilterAction.ACCEPT,Log4M.FilterAction.NEUTRAL,Log4M.FilterAction.DENY};
        allEmptyRegexes={{},'',[],"",{''},{""}};

        matchingInputs={'abcTEST','TESTabc'};
        anyMatchingRegexes={'TEST',"TEST",["TEST","ABC"],["TEST",'ABC'],["TEST",''],{'TEST',""}};

        allMatchingRegexes={'TEST',"TEST",["TEST","TES"],{"TEST",'TES'},{"TEST",''},{'TEST',""}};
        anyMisatchingRegexes={'ABC',"ABC",["TEST","ABC"],{"TEST",'ABC'},{"ABC",''},{'ABC',""}};
    end

    methods(TestMethodSetup)
        function init(obj)
            obj.regexFilter=Log4M.Filters.Regex();
        end
    end

    methods(Test)
        function shouldReturnNeutralOnAnyEmptyInput(obj,allMatchActions,allMismatchActions,allEmptyRegexes)
            obj.regexFilter.setRegex(allEmptyRegexes)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter('abc'),Log4M.FilterAction.NEUTRAL);
        end

        function shouldReturnMatchingOnAnyMatchingInput(obj,allMatchActions,allMismatchActions,matchingInputs)
            obj.regexFilter.setRegex("TEST",obj.regexFilter.MODE_ANY)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter(matchingInputs),allMatchActions);
        end

        function shouldReturnMatchingOnAnyMatchingRegex(obj,allMatchActions,allMismatchActions,anyMatchingRegexes)
            obj.regexFilter.setRegex(anyMatchingRegexes,obj.regexFilter.MODE_ANY)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter('TEST'),allMatchActions);
        end

        function shouldReturnMismatchingOnAnyMismatchingRegex(obj,allMatchActions,allMismatchActions,anyMatchingRegexes)
            obj.regexFilter.setRegex(anyMatchingRegexes,obj.regexFilter.MODE_ANY)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter('TE_ST'),allMismatchActions);
        end

        function shouldReturnMatchingOnAllMatchingRegex(obj,allMatchActions,allMismatchActions,allMatchingRegexes)
            obj.regexFilter.setRegex(allMatchingRegexes,obj.regexFilter.MODE_ALL)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter('TEST'),allMatchActions);
        end

        function shouldReturnMisatchingOnAnyMisatchingRegex(obj,allMatchActions,allMismatchActions,anyMisatchingRegexes)
            obj.regexFilter.setRegex(anyMisatchingRegexes,obj.regexFilter.MODE_ALL)...
                           .onMatch(allMatchActions)...
                           .onMismatch(allMismatchActions);
            obj.verifyEqual(obj.regexFilter.applyFilter('TEST'),allMismatchActions);
        end
    end
end