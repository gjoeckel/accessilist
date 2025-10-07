<?php
/**
 * Application Configuration
 *
 * Determines the base path for assets based on the environment.
 * This is the single source of truth for environment detection.
 */

// Determine if running on local development environment
$isLocal = $_SERVER['HTTP_HOST'] === 'localhost' ||
           $_SERVER['HTTP_HOST'] === '127.0.0.1' ||
           strpos($_SERVER['HTTP_HOST'], 'local') !== false;

// Set base path for all assets (CSS, JS, images, PHP files)
// Local: '' (root)
// Production: '/training/online/accessilist'
$basePath = $isLocal ? '' : '/training/online/accessilist';

