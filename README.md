Initial release of Log4J port for MATLAB.

Features:
- Highlights
   - Single line logs for small projects possible
   - Highly configurable for larger projects with multiple appenders and filters
   - Three example files at different depth
   - Fully deployment compatible
- Dynamic variable resolution
   - Various supported atomic data types which are casted automatically
      - String
      - char
      - categorical
      - numeric
      - datetime
      - duration
      - logical
      - exception (printing their stack)
      - function handle
      - objects of arbitrary classes
    - ...as well as combined structures thereof:
      - arrays
      - cell arrays
      - tables
      - timetables
      - dictionaries
- Appenders
   - Console appender:
      - Fast feedback during development
      - Dynamic links to message source in the implementation code facilitating quick debugging
   - File appender
   - Memory appender
      - Dynamic logging to memory
	  - Table output format allows programmatic filtering of messages after runtime
   - Open interface for future extension
- Regex filter
   - Can be configured for Loggers and Appenders
   - Open filter interface for future extension
- 8 log levels
  Configurable for Loggers and Appenders
