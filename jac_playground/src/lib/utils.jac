

cl import from "clsx" {clsx, ClassValue }
cl import from "tailwind-merge" { twMerge }



cl {
   def cn(input:any) -> str{
      inputs = [].slice.call(arguments);
      return twMerge(clsx(inputs));

   }
}