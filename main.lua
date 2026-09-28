-- Kanto in Motion Assets
-- Shared asset provider for the Kanto in Motion core mod.
--
-- Keep heavy artwork in this mod and let Kanto in Motion access it through
-- mod.find("kanto_in_motion_assets").exports.

return function(mod)
  mod.exports = mod.exports or {}

  -- Public API version. Bump this only if the exported function contract
  -- changes in an incompatible way.
  mod.exports.api_version = 1
  mod.exports.asset_version = mod.version

  local function validRelative(relative)
    if type(relative) ~= "string" or relative == "" then
      return nil
    end

    -- Keep callers consistent across Windows / Linux / Android.
    relative = relative:gsub("\\", "/")
    relative = relative:gsub("^%./", "")
    return relative
  end

  -- Returns the file/directory info table, or nil when the asset is missing.
  mod.exports.info = function(relative)
    relative = validRelative(relative)
    if not relative then return nil end

    local ok, info = pcall(function()
      return mod:info(relative)
    end)
    if not ok then return nil end
    return info
  end

  -- True when a file or directory exists in this asset pack.
  mod.exports.exists = function(relative)
    return mod.exports.info(relative) ~= nil
  end

  -- Returns a safe filesystem path only when the requested asset exists.
  -- Returning nil for missing artwork lets KIM fall back to native sprites.
  mod.exports.path = function(relative)
    relative = validRelative(relative)
    if not relative then return nil end
    if not mod.exports.exists(relative) then return nil end

    local ok, path = pcall(function()
      return mod.assets:path(relative)
    end)
    if not ok then return nil end
    return path
  end

  -- Returns a cached Love2D Image when the requested file exists.
  -- Returns nil instead of throwing when an image is unavailable, allowing
  -- the core mod to fail open to native Gen1Recomp artwork.
  mod.exports.image = function(relative)
    relative = validRelative(relative)
    if not relative then return nil end

    local info = mod.exports.info(relative)
    if not info or info.type ~= "file" then return nil end

    local ok, image = pcall(function()
      return mod.assets:image(relative)
    end)
    if not ok then
      if mod.log and mod.log.warn then
        mod.log:warn("Could not load asset image '%s': %s", relative, tostring(image))
      end
      return nil
    end
    return image
  end

  -- Optional helpers for metadata/index files stored with the asset pack.
  mod.exports.read = function(relative)
    relative = validRelative(relative)
    if not relative then return nil, "invalid asset path" end
    return mod:read(relative)
  end

  mod.exports.list = function(relative)
    relative = validRelative(relative or ".") or "."
    local ok, names = pcall(function()
      return mod:list(relative)
    end)
    if not ok then return {} end
    return names or {}
  end

  if mod.log and mod.log.info then
    mod.log:info("Kanto in Motion Assets %s ready (API %d)", tostring(mod.version), mod.exports.api_version)
  end
end
