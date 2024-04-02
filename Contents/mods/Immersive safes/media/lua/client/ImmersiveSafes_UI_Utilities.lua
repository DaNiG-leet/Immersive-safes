local module = {}

-- Part of my modding lib

module.addMouseMoving = function(UI)
    function UI:onMouseMove(dx, dy)
        self.mouseOver = true
        if self.moving then
            self:setX(self.x + dx)
            self:setY(self.y + dy)
            self:bringToTop()
        end
    end
    
    function UI:onMouseMoveOutside(dx, dy)
        self.mouseOver = false
        if self.moving then
            self:setX(self.x + dx)
            self:setY(self.y + dy)
            self:bringToTop()
        end
    end
    
    function UI:onMouseDown(x, y)
        if not self:getIsVisible() then return end
        self.downX = x
        self.downY = y
        self.moving = true
        self:bringToTop()
    end
    
    function UI:onMouseUp(x, y)
        if not self:getIsVisible() then return end
        self.moving = false
        if ISMouseDrag.tabPanel then ISMouseDrag.tabPanel:onMouseUp(x, y) end
        ISMouseDrag.dragView = nil
    end

    function UI:onMouseUpOutside(x, y)
        if not self:getIsVisible() then return end
        self.moving = false
        ISMouseDrag.dragView = nil
    end
end

module.addBaseUI = function(UI, onInfoText)
    module.addMouseMoving(UI)
end

return module