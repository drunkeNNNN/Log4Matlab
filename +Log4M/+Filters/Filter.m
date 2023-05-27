classdef Filter < handle
    properties(Access=private)
        onMatchAction=Log4M.FilterAction.NEUTRAL;
        onMismatchAction=Log4M.FilterAction.NEUTRAL;
    end

    methods(Access=public)
        function result=applyFilter(obj,message)
            doesMatch=obj.matches(message);
            if doesMatch
                result=obj.onMatchAction;
            else
                result=obj.onMismatchAction;
            end
        end
    end

    methods(Abstract,Access=protected)
        filterResult=matches(obj,message);
    end

    methods(Access=public)
        function obj=onMatch(obj,action)
            arguments
                obj Log4M.Filters.Filter;
                action double;
            end
            obj.onMatchAction=action;
        end

        function obj=onMismatch(obj,action)
            arguments
                obj Log4M.Filters.Filter;
                action double;
            end
            obj.onMismatchAction=action;
        end
    end
end