classdef Focus_OMR < handle
   
    properties
        
        date
        cycle
        speed
        
        Root
        
    end
    
    methods
       
        function this = Focus_OMR() 
            
            switch computer
                case 'PCWIN64'
                    this.Root = 'C:\Users\LJP\Documents\MATLAB\these\data_OMR\data\';
            end
            
        end
        
        % -----------------------------------------------------------------
        
        function p = path(this)
           
            p = [this.Root this.cycle filesep this.speed filesep this.date filesep];
            
        end
        
        % -----------------------------------------------------------------
        
        function D = load(this, filename)
           
            D = load([this.path() filename]);
            
        end
    end
    
end