

import from "clsx" {clsx, ClassValue }
import from "tailwind-merge" { twMerge }

def: pub cn(input:any) -> str{
   inputs = [].slice.call(arguments);
   return twMerge(clsx(inputs));
}
