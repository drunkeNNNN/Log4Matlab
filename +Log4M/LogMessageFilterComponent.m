% Abstract class implemented by Logger and Appender, which holds filters
% and log levels
classdef LogMessageFilterComponent < handle
    properties(Access=private)
        filters cell = cell(0);
        logLevel (1,1) double = Log4M.LogLevel.WARN;
    end
    
    methods(Access=public)
        function obj=setLogLevel(obj,level)
            obj.logLevel = level;
        end

        function logLevel=getLogLevel(obj)
            logLevel=obj.logLevel;
        end

        function obj=clearFilters(obj)
            obj.filters=cell(0);
        end

        function obj=addFilter(obj,filter)
            arguments
                obj Log4M.LogMessageFilterComponent;
                filter Log4M.Filters.Filter;
            end
            obj.filters{end+1,1}=filter;
        end
    end

    methods(Access=protected)
        function [isFilterAccepted,isFilterDenied]=getFilterResult(obj,message)
            filterResultActions=cellfun(@(filter)(filter.applyFilter(message)),obj.filters,'UniformOutput',true);
            isFilterAccepted=any(filterResultActions==Log4M.FilterAction.ACCEPT);
            isFilterDenied=any(filterResultActions==Log4M.FilterAction.DENY);
        end
    end
end

