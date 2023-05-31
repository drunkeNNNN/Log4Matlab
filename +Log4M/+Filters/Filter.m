classdef Filter < handle
    properties(Access=private)
        onMatchAction (1,1) {Log4M.FilterAction}=Log4M.FilterAction.ACCEPT;
        onMismatchAction (1,1) {Log4M.FilterAction}=Log4M.FilterAction.DENY;
    end

    methods(Access=public)
        function result=applyFilter(obj,message)
            arguments
                obj;
                message (1,:) char;
            end
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