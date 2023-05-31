classdef GUI < Log4M.Appenders.Memory
    properties(Constant,Access=private)
        FIGURE_TITLE='Log4M Viewer';
    end

    properties(Access=private)
        figureEnabled=true;
    end

    properties(Access=protected)
        doesShow;
    end

    methods(Access=public)
        function enableFigure(obj)
            obj.figureEnabled=true;
        end

        function disableFigure(obj)
            obj.figureEnabled=false;
        end

        % Hook for subclasses to activate and deactivate the window

        function appendToLog(obj,levelStr,sourceFilename,sourceLink,message,errorLineLink)
            obj.appendToLog@Log4M.Appenders.Memory(levelStr,sourceFilename,sourceLink,message,errorLineLink);

            if obj.figureEnabled
                f = findall(0,'Name',obj.FIGURE_TITLE);
                if isempty(f)
                    f=uifigure('Name',obj.FIGURE_TITLE);
                end
                uiTab=findall(f,'Type','uitable');
                if isempty(uiTab)
                    table=obj.getTable();
                    table{:,2}=double(table{:,2});
                    uiTab=uitable(f,'Data',table(:,[1,2,3,5,6,7]),'ColumnSortable',true(1,6),'ColumnWidth','fit','Units','normalized','Position',[0,0.1,1,0.9]);
                    %                p=uipanel(f,'Units','normalized');
                    uiTab.addStyle(uistyle('Interpreter','html'));

                    uibutton(f,'Text','Update','Visible',true,'Position',[10,10,100,20]);
                    uilabel(f,'Text','Filter Regex','Position',[120,10,100,20]);
                    uieditfield(f,'Position',[240,10,100,20]);
                end
                set(f,"WindowKeyPressFcn",@obj.update);
                btn=findall(f,'Type','uibutton');
                set(btn,'ButtonPushedFcn',@obj.update);
            end
        end

        function update(obj,app,event)
            f = findall(0,'Name',obj.FIGURE_TITLE);
            if isempty(f)
                f=uifigure('Name',obj.FIGURE_TITLE);
                clf(f);
            end

            table=obj.getTable();
            filterStr=get(findall(f,'Type','uieditfield'),'Value');
            if ~isempty(strtrim(filterStr))
                filter=Log4M.Filters.Regex().setRegex(filterStr);
                selected=cellfun(@(x,y,z)(filter.applyFilter([x,y,z])==Log4M.FilterAction.ACCEPT),table{:,end-1},table{:,5},table{:,3});
            else
                selected=true(size(table,1),1);
            end
            table{:,2}=double(table{:,2});
            uiTab=findall(f,'Type','uitable');

            try
                uiTab.Data=table(selected,[1,2,3,5,6,7]);
                uiTab.addStyle(uistyle('Interpreter','html'));
                uiTab.addStyle(uistyle('FontColor', [.2,.2,.2]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.TRACE));
                uiTab.addStyle(uistyle('FontColor', [.1,.1,.1]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.DETAIL));
                uiTab.addStyle(uistyle('FontColor', [.05,.05,.05]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.DEBUG));
                uiTab.addStyle(uistyle('BackgroundColor', [1,1,1]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.INFO));
                uiTab.addStyle(uistyle('BackgroundColor', [1,.95,0.9]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.WARN));
                uiTab.addStyle(uistyle('BackgroundColor', [1,.9,0.9]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.ERROR));
                uiTab.addStyle(uistyle('BackgroundColor', [1,.85,0.85]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.CRITICAL));
                uiTab.addStyle(uistyle('BackgroundColor', [1,.8,0.8]),"row",find(uiTab.Data{:,3}==Log4M.LogLevel.FATAL));
            end
            uiTab.scroll("bottom");
        end
    end
end

