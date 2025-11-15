/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  distDir: '../../build/client',
  reactStrictMode: true,
  images: {
    unoptimized: true
  },
  // Next.js 15 automatically uses Turbopack in dev and optimized builds
  // swcMinify is now default and doesn't need to be specified
  compress: true,
  poweredByHeader: false,
  // Performance optimizations
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production'
  },
  // Enable experimental features for better performance
  experimental: {
    // Optimized package imports for faster builds
    optimizePackageImports: ['react-hot-toast']
  }
}

module.exports = nextConfig
