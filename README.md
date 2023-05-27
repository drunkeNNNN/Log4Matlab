Initial release of Log4J port for MATLAB.

Features:
- Fast adoption
   - Well-known principle
   - Example files available
- Dynamic variable resolution
   - Various supported atomic data types without manual casting
      - String
      - char
      - numeric
      - datetime
      - duration
    - ...and combined structures thereof
      - arrays
      - cell arrays
      - tables
- Appenders
   - Console appender:
      - Fast feedback during development
      - Dynamic links to message source in the implementation code facilitating quick debugging
   - File appender
   - Memory appender
      - Dynamic logging to memory
	  - Table output format allows programmatic filtering of messages after runtime
   - Open interface for future extension
- Filters
   - Configurable for Loggers and Appenders
   - Regex filter
   - Open interface for future extension
- 8 log levels
  Configurable for Loggers and Appenders
