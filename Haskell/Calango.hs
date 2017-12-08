data Animal = Animal { name :: String
               , stomach :: Int
               , energy :: Int
               , life :: Int
               , caress :: Int
               , turns :: Int
               , isSleep :: Bool
               } deriving (Show)

main = do
  putStrLn ("Bem vindo!\n")

  putStrLn ("Qual o nome do seu bichinho?")
  nomeBichinho <- getLine
  let novoAnimal = Animal { name = nomeBichinho, stomach = 75, life = 100, caress = 100, energy = 100, turns = 1, isSleep = False }
  menu novoAnimal False

  putStrLn "\nO programa foi encerrado"

menu :: Animal -> Bool -> IO Animal
menu animal False = do
 putStrLn ("")
 putStrLn ("1 - Alimentar")
 putStrLn ("2 - Ir ao Banheiro")
 putStrLn ("3 - Desligar a luz")
 putStrLn ("4 - Acariciar")
 putStrLn ("0 - Sair")
 option <- getLine
 executeOption animal (read option::Int) False

menu animal True = do
  putStrLn ("")
  putStrLn ("1 - Ligar luz")
  putStrLn ("2 - Continuar dormindo")
  putStrLn ("0 - Sair")
  option <- getLine
  executeOption animal (read option::Int) True

executeOption :: Animal -> Int -> Bool -> IO Animal
executeOption animal 1 False = feed (decreaseByRound animal)
executeOption animal 1 True = wakeUp (decreaseByRound animal)
executeOption animal 2 True = sleep (decreaseByRound animal)
executeOption animal 3 False = sleep (decreaseByRound animal)
executeOption animal 4 False = toCaress (decreaseByRound animal)
executeOption animal 0 anyValue = return (decreaseByRound animal)
executeOption animal _ anyValue = do
                           putStrLn("\nOpção Inválida! Tente novamente...")
                           putStr("\nPressione <Enter> para voltar ao menu...")
                           getChar
                           menu animal anyValue


decreaseByRound :: Animal -> Animal
decreaseByRound (Animal { name = n, stomach = s, life = l, caress = c, energy = e, turns = t, isSleep = sleep}) = Animal {
  name = n,
  stomach = if(s <= 5) then 0 else (s - 5),
  life = if calculateLife l s e sleep <= 0 then 0 else calculateLife l s e sleep,
  caress = if(c <= 10) then 0 else (c - 10),
  energy = if (sleep) then e + 20 else e - 5,
  turns = (t + 1),
  isSleep = sleep
}

calculateLife:: Int -> Int -> Int -> Bool -> Int
calculateLife life stomach energy sleep = life - (calculateLifeDescontByEnergy energy) - (calculateLifeDescontByStomach stomach) + (calculateLifeIncreaseBySleep sleep)

calculateLifeDescontByStomach:: Int -> Int
calculateLifeDescontByStomach stomach = if (stomach <= 15) then 20 else 0

calculateLifeDescontByEnergy:: Int -> Int
calculateLifeDescontByEnergy energy = if (energy <= 30) then 20 else 0

calculateLifeIncreaseBySleep:: Bool -> Int
calculateLifeIncreaseBySleep isSleep = if isSleep then 2 else 0
-- Ainda não há conceito de níveis, nem de experiência
-- As interações ainda não verifica estados dos atributos (se atingiu limite superior ou se chegou abaixo de 0)
feed :: Animal -> IO Animal
feed animal = do
              let updatedAnimal = calcFeed animal
              putStrLn (showStatus updatedAnimal)
              menu updatedAnimal False

calcFeed :: Animal -> Animal
calcFeed Animal { name = n, stomach = s, life = l, caress = c, energy = e, turns = t, isSleep = sleep } = Animal {
  name = n,
  stomach = if(s >= 75) then 100 else (s + 25),
  life = l,
  caress = if(c >= 95) then 100 else (c + 5),
  energy = e,
  turns = t + 1,
  isSleep = sleep}

wakeUp :: Animal -> IO Animal
wakeUp animal = do
    let updatedAnimal = calcWakeUp animal
    putStrLn (showStatus updatedAnimal)
    menu updatedAnimal False

calcWakeUp :: Animal -> Animal
calcWakeUp Animal { name = n, stomach = s, life = l, caress = c, energy = e, turns = t, isSleep = sleep } = Animal {
    name = n,
    stomach = s,
    life = l,
    caress = if(c >= 95) then 100 else (c + 5),
    energy = e,
    turns = t + 1,
    isSleep = False}

-- Função sleep única: Ainda não há o estado "dormindo"
sleep :: Animal -> IO Animal
sleep animal = do
               let updatedAnimal = calcSleep animal
               putStrLn (showStatus updatedAnimal)
               menu updatedAnimal True

calcSleep :: Animal -> Animal
calcSleep (Animal { name = n, stomach = h, life = l, caress = c, energy = e, turns = t, isSleep = sleep}) = Animal {
  name = n,
  stomach = h,
  life = l + 2,
  caress = c,
  energy = if(e >= 80) then 100 else (e + 20),
  turns = (t + 1),
  isSleep = True }


toCaress :: Animal -> IO Animal
toCaress animal = do
                  let updatedAnimal = calcToCaress animal
                  putStrLn (showStatus updatedAnimal)
                  menu updatedAnimal False

calcToCaress :: Animal -> Animal
calcToCaress (Animal { name = n, stomach = h, life = l, caress = c, energy = e, turns = t, isSleep = sleep}) = Animal {
  name = n,
  stomach = h,
  life = l,
  caress = c + 40,
  energy = e ,
  turns = (t + 1),
  isSleep = sleep}

-- Sem função de limpar tela, por enquanto
showStatus :: Animal -> String
showStatus (Animal {name = n, stomach = h, life = l, caress = c, energy = e,
               turns = t, isSleep = sleep})
    | h <= 20 = "PERIGO EMINENTE!!! " ++ n ++ " está a com fome alta, alimente-o já!\n" ++ status
    | c <= 20 = "CARÊNCIA CRÍTICA!! Parece que você é um verdadeito BRUTA-MONTES, cuide do seu calango seu(a) cabra da peste!!\n" ++ status
    | e <= 30 = "SONO CRÍTICO!!! " ++ n ++ " precisa de um descanso ou não terá energia para escapar de predadores. Apague a luz!\n" ++ status
    | otherwise = status
    where status = "Nome: " ++ n ++ "\nVida: " ++ show l ++ " Estomago: " ++ show h ++ "% Carinho: " ++ show c ++ "% Energia: "
                      ++ show e ++ "%"
