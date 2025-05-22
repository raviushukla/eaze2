import js from "@eslint/js";
import pluginReact from "eslint-plugin-react";
import pluginLwc from "@lwc/eslint-plugin-lwc";
import globals from "globals";

export default [
  {
    files: ["*/.{js,mjs,cjs,jsx}"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.jest, // 👈 Add this line
        require: "readonly",
        module: "readonly"
      }
    },
    plugins: {
      react: pluginReact,
      lwc: pluginLwc
    },
    rules: {
      ...js.configs.recommended.rules,
      "react/react-in-jsx-scope": "off",
      "react/prop-types": "off"
    },
    settings: {
      react: {
        version: "detect"
      }
    }
  }
];