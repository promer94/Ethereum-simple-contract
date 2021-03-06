module.exports = {
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 2017
  },
  extends: ['react-app', 'airbnb', 'prettier/react', 'prettier'],
  rules: {
    'jsx-a11y/href-no-hash': [0],
    'jsx-a11y/label-has-for': [0],
    'generator-star-spacing': [0],
    'consistent-return': [0],
    'react/react-in-jsx-scope': [0],
    'react/forbid-prop-types': [0],
    'react/jsx-filename-extension': [1, { extensions: ['.js', '.jsx'] }],
    'global-require': [1],
    'import/prefer-default-export': [0],
    'react/prop-types': [0],
    'react/prefer-stateless-function': [0],
    'no-else-return': [0],
    'no-restricted-syntax': [0],
    'import/no-extraneous-dependencies': [0],
    'no-use-before-define': [0],
    'jsx-a11y/no-static-element-interactions': [0],
    'no-nested-ternary': [0],
    'arrow-body-style': [0],
    'import/extensions': [0],
    'no-bitwise': [0],
    'class-methods-use-this': [0],
    'import/no-unresolved': [0],
    'require-yield': [1],
    'no-param-reassign': [0],
    'no-shadow': [0],
    'no-underscore-dangle': [0],
    'spaced-comment': [0],
    'func-names': [0],
    'no-console': [2],
    'import/no-dynamic-require': [0],
    'react/sort-comp': [0],
    semi: ['error', 'never'],
    'prettier/prettier': ['error', { singleQuote: true, semi: false }]
  },
  plugins: ['prettier']
}
