classdef Focus < handle
   
    properties
        
        date
        
        Root
        
    end
    
    methods
       
        function this = Focus() 
            
            switch computer
                case 'PCWIN64'
                    this.Root = 'C:\Users\LJP\Documents\MATLAB\these\data_OMR\data_spontaneous\';
            end
            
        end
        
        % -----------------------------------------------------------------
        
        function p = path(this)
           
            p = [this.Root (this.date)];
            
        end
        
        % -----------------------------------------------------------------
        
        function D = load(this, filename)
           
            D = load([this.path() filename]);
            
        end
    end
    
end