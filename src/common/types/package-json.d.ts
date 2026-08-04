declare module '../../package.json' {
  interface PackageJson {
    name: string;
    version: string;
    // Add other properties you might need from package.json
  }
  const value: PackageJson;
  export default value;
}
