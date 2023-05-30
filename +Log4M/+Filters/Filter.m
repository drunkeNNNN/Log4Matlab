classdef Filter < handle
    properties(Access=private)
        onMatchAction=Log4M.FilterAction.ACCEPT;
        onMismatchAction=Log4M.FilterAction.DENY;
    end

    methods(Access=public)
        function result=applyFilter(obj,message)
            if ~obj.isEnabled()
                result=Log4M.FilterAction.NEUTRAL;
            elseif obj.matches(message)
                result=obj.onMatchAction;
            else
                result=obj.onMismatchAction;
            end
        end
    end

    methods(Abstract,Access=protected)
        enabled=isEnabled(obj);
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