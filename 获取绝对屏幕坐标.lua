EnablePrimaryMouseButtonEvents(true)

function OnEvent(event, arg)
    if event == "MOUSE_BUTTON_PRESSED" and arg == 3 then
        local x, y = GetMousePosition()
        OutputLogMessage("MousePosition: {%d, %d}\n", x, y)
    end
end