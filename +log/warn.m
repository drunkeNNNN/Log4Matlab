% Convenience wrapper for warn log. Call log.init(filename) first.
function warn(varargin)
    logger=Log4M.Logger.getInstance();
    logger.warn(varargin{:});
end