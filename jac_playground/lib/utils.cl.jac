

import from "clsx" {clsx }
import from "tailwind-merge" { twMerge }

def: pub cn(input:any) -> str{
   inputs = [].slice.call(arguments);
   return twMerge(clsx(inputs));
}
