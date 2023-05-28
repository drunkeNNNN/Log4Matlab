function setFilter(filterRegex)
    arguments
        % Char, string or cell array of chars or strings
        filterRegex;
    end
    logger=Log4M.Logger.getInstance();
    logger.clearFilters();
    logger.addFilter(Log4M.Filters.Regex().setRegex(filterRegex,Log4M.Filters.Regex.MODE_ANY)...
                                          .onMatch(Log4M.FilterAction.ACCEPT)...
                                          .onMismatch(Log4M.FilterAction.DENY));
end