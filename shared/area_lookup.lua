local AreaLookup = {}

---The area whose landmark is closest to `position`, if it's within the data's proximity threshold.
---@param position {x: number, y: number}
---@param area_data {proximity_threshold?: number, areas: table<string, {landmarks: {x: number, y: number}[]}>}
---@return string|nil
function AreaLookup.area_at(position, area_data)
    local closest_area, closest_distance = nil, math.huge
    for area_id, area in pairs(area_data.areas) do
        for _, landmark in ipairs(area.landmarks or {}) do
            local distance = math.sqrt((position.x - landmark.x) ^ 2 + (position.y - landmark.y) ^ 2)
            if distance < closest_distance then
                closest_area, closest_distance = area_id, distance
            end
        end
    end
    if closest_distance < (area_data.proximity_threshold or 50) then return closest_area end
end

return AreaLookup
