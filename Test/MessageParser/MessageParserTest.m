classdef MessageParserTest < matlab.unittest.TestCase
    properties(Access=private)
        messageParser;

        outputLines;
        outputErrorLines;

        TEST_CHAR='TEST';
        TEST_CHAR_2=' CHAR_2';

        TEST_STRING="STRING";

        TEST_DOUBLE=2;

        TEST_DATETIME_1=datetime(2022,06,24,12,13,21,314);
        TEST_DATETIME_2=datetime(2022,06,26,14,14,22,315);
        TEST_DATETIME_VEC=[datetime('now'),datetime('yesterday')];
    end

    methods(TestMethodSetup)
        function setupMethod(obj)
            obj.messageParser=Log4M.Core.MessageParser();
            obj.messageParser.setNumericFormat('%g');
        end
    end

    methods(Test)
        function shouldParseRandomObject(obj)
            lec=Log4M.LogLevel();
            obj.verifyThatOutputFor('Object: ',lec);
            obj.matches('Object:.* with properties:','inLine',1);
            for i=2:size(obj.outputLines,1)
                obj.matches('Object: \w+: \d','inLine',i);
            end
        end

        function shouldParseError(obj)
            [path,fname,ext]=fileparts(mfilename('fullpath'));
            load([path,filesep,'testException.mat'],'exception');

            obj.verifyThatOutputFor('EX: ',exception)...
                .matches('EX: ERROR: MException\(\): Program terminated\. See logs\.','inLine',1)...
                .matches('EX: ERROR STACK 1:LogExampleClass\.m \(Line 22\)','inLine',2)...
                .matches('EX: ERROR STACK 2:log4MAdvancedExample\.m \(Line 161\)','inLine',3)...
                .hasLineCount(3)...
                .hasEmptyErrorLink('inLine',1)...
                .hasValidErrorLinkInLine(2)...
                .hasValidErrorLinkInLine(3);
        end

        function shouldParseTimeTable(obj)
            itemDates=[datetime("now");datetime("tomorrow")];
            itemCats=categorical(["CAT_A";"CAT_BD"]);
            itemValues=[10;20];
            testTimetable=timetable(itemDates,itemCats,itemValues);

            dateRegex='\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3}';
            obj.verifyThatOutputFor(testTimetable)...
                .matches('Time, itemCats, itemValues','inLine',1)...
                .matches([dateRegex,', CAT_A, 10'],'inLine',2)...
                .matches([dateRegex,', CAT_BD, 20'],'inLine',3)...
                .hasEmptyErrorLink()...
                .hasLineCount(3);
        end

        function shouldParseTable(obj)
            itemCats=categorical(["CAT_A";"CAT_BD";"CAT_BD"]);
            itemValues=[10;20;30];
            testTable=table(itemCats,itemValues);

            obj.verifyThatOutputFor(testTable)...
                .matches('itemCats, itemValues','inLine',1)...
                .matches('CAT_A, 10','inLine',2)...
                .matches('CAT_BD, 20','inLine',3)...
                .matches('CAT_BD, 30','inLine',4)...
                .hasEmptyErrorLink()...
                .hasLineCount(4);
        end

        function shouldThrowErrorOnMultilineCellContent(obj)
            import matlab.unittest.constraints.*;
            obj.verifyThat(@()(obj.messageParser.parseMessage({[1;2],[1;2]})),...
                           Throws('Log4M:MessageParser:InvalidInput'));
        end

        function shouldParseSingleLineCellContent(obj)
            obj.verifyThatOutputFor({[1,2,3],[4,5,6]})...
                .matches('1, 2, 3, 4, 5, 6','inLine',1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseCellArray(obj)
            obj.verifyThatOutputFor('a cell array: ', {1, 1;"abc",'def geh'})...
                .matches('a cell array: 1, 1',"inLine",1)...
                .matches('a cell array: abc, def geh','inLine',2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldThrowErrorOnSecondMultilineChange(obj)
            import matlab.unittest.constraints.*;
            obj.verifyThat(@()(obj.messageParser.parseMessage([1;2],[1;2;3])),...
                          Throws('Log4M:MessageParser:InvalidInput'))
            obj.verifyThat(@()(obj.messageParser.parseMessage([1;2;3],[1;2])),...
                          Throws('Log4M:MessageParser:InvalidInput'))
        end

        function shouldParseDuration(obj)
            obj.verifyThatOutputFor(obj.TEST_DATETIME_1-obj.TEST_DATETIME_2)...
                .matches('-02:02:01:01.001',"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseDatetimeVec(obj)
            obj.verifyThatOutputFor([obj.TEST_DATETIME_1,obj.TEST_DATETIME_2])...
                .matches('2022-06-24 12:13:21.314, 2022-06-26 14:14:22.315',"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseFunctionHandle(obj)
            obj.verifyThatOutputFor(@mean,', ',@max)...
                .matches('@mean, @max',"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseLogicalVec(obj)
            obj.verifyThatOutputFor([false,true,true])...
                .matches('FALSE(, TRUE){2}',"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseCatVec(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR, categorical(["A","A","B"]))...
                .matches([obj.TEST_CHAR, 'A, A, B'],"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseStringVec(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR,' ',[obj.TEST_STRING,obj.TEST_STRING]);
              obj.matches([obj.TEST_CHAR,' ',char(obj.TEST_STRING),' ',char(obj.TEST_STRING)],"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseStringColVec(obj)
            obj.verifyThatOutputFor([obj.TEST_CHAR;obj.TEST_STRING])...
                .matches(obj.TEST_CHAR,"InLine",1)...
                .matches(obj.TEST_STRING,"InLine",2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldParseStringRowVec(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR,obj.TEST_STRING)...
                .matches([obj.TEST_CHAR,char(obj.TEST_STRING)],"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseNumericArray(obj)
            obj.verifyThatOutputFor([1,2,3,5; ...
                                     3,4,5,6])...
                .matches('1, 2, 3, 5',"InLine",1)...
                .matches('3, 4, 5, 6',"InLine",2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldParseDoubleRowVec(obj)
            obj.verifyThatOutputFor([1,2,3,5])...
                .matches('1, 2, 3, 5',"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseCharNumericColVecChar(obj)
            obj.verifyThatOutputFor('abc ',[1, 2; 3, 4], ' def')...
                .matches('abc 1, 2 def',"inLine",1)...
                .matches('abc 3, 4 def',"inLine",2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldParseCharNumericColVec(obj)
            obj.verifyThatOutputFor('abc ',[1, 2; 3, 4])...
                .matches('abc 1, 2',"inLine",1)...
                .matches('abc 3, 4',"inLine",2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldParseNumericFormat(obj)
            obj.messageParser.setNumericFormat('%.5f');
            obj.verifyThatOutputFor('x: ',2)...
                .matches('x: 2.0{5}',"inLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseCharNumeric(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR,obj.TEST_DOUBLE)...
                .matches([obj.TEST_CHAR,num2str(obj.TEST_DOUBLE)],"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldParseNumeric(obj)
            obj.verifyThatOutputFor(obj.TEST_DOUBLE)...
                .matches(num2str(obj.TEST_DOUBLE),"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldConcatenateChars(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR,obj.TEST_CHAR_2)...
                .matches([obj.TEST_CHAR,obj.TEST_CHAR_2],"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldAddCharArrayToOutputLines(obj)
            obj.verifyThatOutputFor([obj.TEST_CHAR;obj.TEST_CHAR])...
                .matches(obj.TEST_CHAR,"InLine",1)...
                .matches(obj.TEST_CHAR,"InLine",2)...
                .hasEmptyErrorLink()...
                .hasLineCount(2);
        end

        function shouldAddCharToOutputLines(obj)
            obj.verifyThatOutputFor(obj.TEST_CHAR)...
                .matches(obj.TEST_CHAR,"InLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end

        function shouldReturnSingleLineOutputWithNoInput(obj)
            obj.verifyThatOutputFor()...
                .matches('',"inLine",1)...
                .hasEmptyErrorLink()...
                .hasLineCount(1);
        end
    end

    methods(Access=private)
        function obj=matches(obj,outputRegex,target)
            arguments
                obj;
                outputRegex char;
                target.inLine;
            end
            import matlab.unittest.constraints.*;

            obj.verifyOutputIsChar(target.inLine);
            obj.verifyTrue(matches(obj.outputLines{target.inLine,1},regexpPattern(outputRegex)));
        end

        function obj=hasValidErrorLinkInLine(obj,line)
            arguments
                obj;
                line double;
            end
            import matlab.unittest.constraints.*;
            obj.verifyTrue(startsWith(obj.outputErrorLines{line,1},'<a href="matlab:opentoline'));
        end

        function obj=hasEmptyErrorLink(obj,target)
            arguments
                obj;
                target.inLine double = 1:size(obj.outputLines,1);
            end
            import matlab.unittest.constraints.*;
            for i=1:size(target.inLine,2)
                obj.verifyThat(obj.outputErrorLines{target.inLine(i),1},IsEmpty);
            end
        end
        
        function obj=verifyThatOutputFor(obj,varargin)
            [obj.outputLines,obj.outputErrorLines]=obj.messageParser.parseMessage(varargin{:});
        end

        function verifyOutputIsChar(obj,inLine)
            import matlab.unittest.constraints.*;
            obj.verifyThat(obj.outputLines{inLine,1},IsOfClass('char'));
            obj.verifyThat(obj.outputErrorLines{inLine,1},IsOfClass('char'));
        end

        function obj=hasLineCount(obj,expectedLineCount)
            import matlab.unittest.constraints.*;
            obj.verifyOutputSameSize();
            obj.verifyThat(obj.outputLines,HasSize([expectedLineCount,1]));
            obj.verifyThat(obj.outputErrorLines,HasSize([expectedLineCount,1]));
        end

        function verifyOutputSameSize(obj)
            obj.verifyEqual(size(obj.outputLines),size(obj.outputErrorLines));
        end
    end
end