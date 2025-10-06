<?php
/**
 * Type Manager - Centralized type handling for AccessiList
 */

class TypeManager {
    private static $typeConfig = null;

    private static function loadConfig() {
        if (self::$typeConfig === null) {
            $configFile = __DIR__ . '/../../config/checklist-types.json';
            if (file_exists($configFile)) {
                $config = json_decode(file_get_contents($configFile), true);
                self::$typeConfig = $config ?: [];
            } else {
                self::$typeConfig = [];
            }
        }
        return self::$typeConfig;
    }

    public static function getAvailableTypes() {
        $config = self::loadConfig();
        return array_keys($config['types'] ?? []);
    }

    public static function getDefaultType() {
        $config = self::loadConfig();
        return $config['defaultType'] ?? 'camtasia';
    }

    public static function validateType($type) {
        if (!is_string($type) || $type === '') {
            return null;
        }
        $validTypes = self::getAvailableTypes();
        return in_array($type, $validTypes, true) ? $type : null;
    }

    public static function formatDisplayName($typeSlug) {
        if (empty($typeSlug)) {
            return 'Unknown';
        }
        $config = self::loadConfig();
        $typeData = $config['types'][$typeSlug] ?? null;
        if ($typeData && isset($typeData['displayName'])) {
            return $typeData['displayName'];
        }
        return ucfirst($typeSlug);
    }

    public static function convertDisplayNameToSlug($displayName) {
        if (!is_string($displayName) || $displayName === '') {
            return self::getDefaultType();
        }
        $config = self::loadConfig();
        foreach (($config['types'] ?? []) as $slug => $data) {
            if (isset($data['displayName']) && strcasecmp($data['displayName'], $displayName) === 0) {
                return $slug;
            }
        }
        // naive fallback
        $candidate = strtolower(trim($displayName));
        return self::validateType($candidate);
    }
}
?>


