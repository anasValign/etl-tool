import { extendTheme } from '@chakra-ui/react';

import '@fontsource-variable/manrope';

const defaultExtension = {
  colors: {
    mw_orange: '#b7ed3f',
    brand: {
      100: '#FFE7E6',
      200: '#FAC5C3',
      300: '#F5837F',
      400: '#F54C3D',
      500: '#CC1C16',
      600: '#720D09',
    },
    gray: {
      100: '#FFFFFF',
      200: '#F9FAFB',
      300: '#F2F4F7',
      400: '#EAECF0',
      500: '#D0D5DD',
      600: '#98A2B3',
    },
    black: {
      100: '#667085',
      200: '#475467',
      300: '#344054',
      400: '#1D2939',
      500: '#10182B',
      600: '#000000',
    },
    success: {
      100: '#DCF2EF',
      200: '#B7EDE3',
      300: '#71D9C6',
      400: '#33C0A7',
      500: '#129981',
      600: '#075042',
    },
    warning: {
      100: '#FFE6D4',
      200: '#FFD4B6',
      300: '#FFAF75',
      400: '#FF8F3E',
      500: '#F56412',
      600: '#932C00',
    },
    error: {
      100: '#FFEBEB',
      200: '#FAC5C5',
      300: '#F58E8E',
      400: '#F45757',
      500: '#C82727',
      600: '#761414',
    },
    info: {
      100: '#E0ECFF',
      200: '#BAD6FF',
      300: '#75ACFF',
      400: '#3E8BFF',
      500: '#0E54BD',
      600: '#032C6B',
    },
  },
  components: {
    Button: {
      variants: {
        solid: {
          bgColor: '#b7ed3f',
          _hover: { bgColor: '#b7ed3f' },
          color: 'white',
          _loading: {
            _hover: {
              bgColor: '#b7ed3f',
            },
          },
          _disabled: {
            _hover: {
              bgColor: '#b7ed3f',
            },
          },
        },
        outline: {
          bgColor: '#b7ed3f',
          _hover: { bgColor: '#b7ed3f', color: 'white' },
          color: '#b7ed3f',
          outline: '1px',
          borderColor: '#b7ed3f',
          _loading: {
            _hover: { bgColor: '#b7ed3f', color: 'white' },
          },
          _disabled: {
            _hover: { bgColor: '#b7ed3f', color: 'white' },
          },
        },
        ghost: {
          bgColor: 'gray.400',
          _hover: { bgColor: 'gray.500', color: 'black' },
          color: 'black',
          _loading: {
            _hover: { bgColor: 'gray.500', color: 'black' },
          },
          _disabled: {
            _hover: { bgColor: 'gray.500', color: 'black' },
          },
        },
        shell: {
          bgColor: 'gray.100',
          _hover: { bgColor: 'gray.300', color: 'black' },
          color: 'black',
          borderColor: 'gray.500',
          borderWidth: '1px',
          borderStyle: 'solid',
          _loading: {
            _hover: { bgColor: 'gray.300', color: 'black' },
          },
          _disabled: {
            _hover: { bgColor: 'gray.300', color: 'black' },
          },
        },
      },
      sizes: {
        xs: {
          h: '24px',
          w: '92px',
          px: '8px',
          gap: '6px',
          radius: '6px',
          fontSize: '14px',
          lineHeight: '20px',
          fontWeight: '700',
        },
        sm: {
          h: '32px',
          w: '114px',
          px: '12px',
          gap: '8px',
          radius: '6px',
          fontSize: '14px',
          lineHeight: '20px',
          fontWeight: '700',
        },
        md: {
          h: '40px',
          w: '126px',
          px: '16px',
          gap: '2px',
          radius: '8px',
          fontSize: '14px',
          lineHeight: '20px',
          fontWeight: '700',
        },
        lg: {
          h: '48px',
          w: '157px',
          px: '24px',
          gap: '2px',
          radius: '8px',
          fontSize: '14px',
          lineHeight: '20px',
          fontWeight: '700',
        },
      },
      loading: {
        _hover: {
          bgColor: 'green.200',
        },
      },
    },
    Text: {
      sizes: {
        xl: {
          fontSize: '20px',
          lineHeight: '30px',
        },
        lg: {
          fontSize: '18px',
          lineHeight: '28px',
        },
        md: {
          fontSize: '16px',
          lineHeight: '24px',
          letterSpacing: '-0.16px',
        },
        sm: {
          fontSize: '14px',
          lineHeight: '20px',
          letterSpacing: '-0.14px',
        },
        xs: {
          fontSize: '12px',
          lineHeight: '18px',
        },
        xxs: {
          fontSize: '10px',
          lineHeight: '16px',
        },
      },
      font: 'Manrope',
      weights: {
        regular: 400,
        medium: 500,
        semibold: 600,
        bold: 700,
        extrabold: 800,
      },
    },
    Heading: {
      sizes: {
        xl: {
          fontSize: '60px',
          lineHeight: '72px',
        },
        lg: {
          fontSize: '48px',
          lineHeight: '60px',
        },
        md: {
          fontSize: '36px',
          lineHeight: '44px',
        },
        sm: {
          fontSize: '30px',
          lineHeight: '38px',
        },
        xs: {
          fontSize: '24px',
          lineHeight: '32px',
        },
      },
      weight: {
        800: 'extrabold',
        700: 'bold',
        600: 'semibold',
        500: 'medium',
        400: 'regular',
      },
    },
    Input: {
      variants: {
        outline: {
          field: {
            bg: 'white',
            width: '100%',
            height: '40px',
            border: '1px',
            borderColor: 'gray.400',
            boxSizing: 'border-box',
            borderRadius: 8,
          },
        },
      },
    },
  },

  fonts: {
    heading: 'Manrope, sans-serif',
    body: 'Manrope, sans-serif',
  },
  fontSizes: {
    b3: '1rem',
    b4: '0.875rem',
    b5: '0.75rem',
  },
  lineHeights: {
    b3: '1.5rem',
    b4: '1.25rem',
    b5: '1.125rem',
  },
  letterSpacings: {
    b3: '-0.16px',
    b4: '-0.12px',
  },
  fontWeights: {
    semiBold: 600,
  },
  brandName: 'V-Align',
  logoUrl: '',
};

// Function to extend the theme with environment variables
const extendThemeWithEnv = (env: Record<string, string>) => {
  let extension = { ...defaultExtension };

  // Update the logo URL if environment variable exists
  if (env.VITE_LOGO_URL) {
    extension = {
      ...extension,
      logoUrl: env.VITE_LOGO_URL,
    };
  }

  // Update the brand name if environment variable exists
  if (env.VITE_BRAND_NAME) {
    extension = {
      ...extension,
      brandName: env.VITE_BRAND_NAME,
    };
  }

  // Update the brand color if environment variable exists

  if (env.VITE_BRAND_COLOR) {
    extension = {
      ...extension,
      colors: {
        ...extension.colors,
        brand: {
          ...extension.colors.brand,
          400: env.VITE_BRAND_COLOR,
        },
      },
      components: {
        ...extension.components,
        Button: {
          ...extension.components.Button,
          variants: {
            ...extension.components.Button.variants,
            solid: {
              ...extension.components.Button.variants.solid,
              _hover: { bgColor: env.VITE_BRAND_HOVER_COLOR },
            },
          },
        },
      },
    };
  }

  return extension;
};

const extenstion = extendThemeWithEnv(import.meta.env);

const mwTheme = extendTheme(extenstion);

export default mwTheme;
