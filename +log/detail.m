% Convenience wrapper for detail log. Call log.init(filename) first.
function detail(varargin)
    logger=Log4M.Logger.getInstance();
    logger.detail(varargin{:});
end