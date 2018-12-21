
package uno;

import java.util.*;

public class mpirolleUnoPlayer implements UnoPlayer 
{
//fonctions :
	public static boolean haveColor(Card a)
	{
		return (a.getColor()==Color.RED||a.getColor()==Color.BLUE||a.getColor()==Color.GREEN||a.getColor()==Color.YELLOW);
	}
	public static boolean haveSameColor(Card a,Card b)
	{
		return (a.getColor()==b.getColor());
	}
	public static boolean haveSameColor(Card a,Color c)
	{
		return (a.getColor()==c);
	}
	public static boolean haveSameRank(Card a,Card b)
	{
		return (a.getRank()==b.getRank());
	}
	public static boolean haveSameNum(Card a,Card b)
	{
		return (a.getNumber()==b.getNumber());
	}
	public static boolean IsAJocker(Card a)
	{
		return(a.getRank()==Rank.WILD_D4||a.getRank()==Rank.WILD);
	}
	public static boolean IsNotNumberANotJocker(Card a)
	{
		return(a.getRank()==Rank.REVERSE||a.getRank()==Rank.SKIP||a.getRank()==Rank.DRAW_TWO);
	}

	public static List<Integer> cardList(List<Card> hand, Card upCard, Color calledColor)
	{
		List<Integer> res = new ArrayList<>();
		for (int i=0;i<hand.size();i++)
		{
			if (IsAJocker(hand.get(i)))
			{
				res.add(i);
			}
			else if (upCard.getRank()== Rank.WILD&&haveSameColor(hand.get(i),calledColor))
			{
				res.add(i);
			}
			else if (upCard.getRank()==Rank.WILD_D4&&haveSameColor(hand.get(i),calledColor))
			{
				res.add(i);
			}
			else if (upCard.getRank()==Rank.NUMBER&&(haveSameNum(hand.get(i),upCard)||haveSameColor(hand.get(i),upCard)))
			{
				res.add(i);
			}
			else if (IsNotNumberANotJocker(upCard)&&(haveSameColor(hand.get(i),upCard)||haveSameRank(hand.get(i),upCard)))
    		{
				res.add(i);
    		}
		}
		return res;
	}

	public static List<Card> reverse(List<Card> l)
    {
		List<Card> res = new ArrayList<Card>();
		for(int i=l.size()-1; i>=0; i--)
		{
		    res.add(l.get(i));
		}
		return res;
    }
    public static int[] vasGagner(int nbCardTab[]) //prend le tableau des carte et return l'id du joueur qui est le mieu avancer et le nombre de carte qui lui reste
    {
    	int[] res=new int[2];
    	int idBest=0;
    	for (int i=0;i<3;i++)
    	{
    		if (nbCardTab[idBest]>nbCardTab[i])
    		{
    			idBest=i;
    		}
    	}
    	res[0]=idBest;
    	res[1]=nbCardTab[idBest];
    	return res;
    }

	public int[] nbCardOtherPlayer={7,7,7}; //enregistre le nombre de carte du jour au tour prévdent
	public int[] nbHavePlayed=new int[3]; //on en desuis si le joueur a jouer ou pas
	public int[][] nbHaveNotPlayed={{0,0,0,0},{0,0,0,0},{0,0,0,0}}; //nombre de fois ou il n'a pas jouer
	public Color[] longuePlayeur=new Color[3];
	public int idLastCardIplay=-1; //premier tour on suppose que la derrnière carte joué est a la position "-1" dans le tableau
	public int lastSens=0; //sens normal
	public List<Card> cardPlayedJ1=new ArrayList<>();
	public List<Card> cardPlayedJ2=new ArrayList<>();
	public List<Card> cardPlayedJ3=new ArrayList<>();

	public void assign(int id,Card carte)
	{
		switch (id) {
			case 0:
				cardPlayedJ1.add(carte);
				break;
			case 1:
				cardPlayedJ2.add(carte);
				break;
			case 2:
				cardPlayedJ3.add(carte);
				break;
			
		}
	}

    public int play(List<Card> hand, Card upCard, Color calledColor,GameState state) 
    {
    	Color[] colorTabID={Color.RED,Color.GREEN,Color.BLUE,Color.YELLOW};
    	int cardId=-1;
    	List<Integer> cardPossible = cardList(hand,upCard,calledColor);
    	
		int[] priorityTap=new int[cardPossible.size()];
		for (int i=0;i<cardPossible.size();i++)
		{
			priorityTap[i]=0;
		}

		//liste de tt els cartes joués
    	List<Card> cardPlayedALL=new ArrayList<>();
    	for (int i=0;i<state.getPlayedCards().size();i++)
    	{
    		cardPlayedALL.add(state.getPlayedCards().get(i));
    	}
    	cardPlayedALL.add(upCard); //on ajoute la derrnière carte pas encore ajuté dans la liste des cartes posés
    	cardPlayedALL.remove(0);//on retire le miermier element non joué par un joueur (catre initial)
    	//


    	//calcule du sence de jeu:
    	int conteurNbChamgnementDeSens=0;
    	for (int i=0;i<cardPlayedALL.size();i++)
    	{
    		if (cardPlayedALL.get(i).getRank()==Rank.REVERSE)
    		{
    			conteurNbChamgnementDeSens++;
    		}
    	}

    	int sensGame=conteurNbChamgnementDeSens%2;
    	//

    	//calcule de le nombre de carte joué
    	for (int i=0;i<3;i++)
    	{
    		if (sensGame==0) //si le sence de jeu est normal:
	    	{
	    		nbHavePlayed[0]=nbCardOtherPlayer[0]-state.getNumCardsInHandsOfUpcomingPlayers()[0];
	    		nbHavePlayed[1]=nbCardOtherPlayer[1]-state.getNumCardsInHandsOfUpcomingPlayers()[1];
	    		nbHavePlayed[2]=nbCardOtherPlayer[2]-state.getNumCardsInHandsOfUpcomingPlayers()[2];
	    	}
	    	else //si il est inversé
	    	{
	    		nbHavePlayed[0]=nbCardOtherPlayer[0]-state.getNumCardsInHandsOfUpcomingPlayers()[2];
	    		nbHavePlayed[1]=nbCardOtherPlayer[1]-state.getNumCardsInHandsOfUpcomingPlayers()[1];
	    		nbHavePlayed[2]=nbCardOtherPlayer[2]-state.getNumCardsInHandsOfUpcomingPlayers()[0];
	    	}
    	}
    	//

    	//sauvegarde du nouveau nombre de cartes
    	if (sensGame==0) //si le sence de jeu est normal:
    	{
    		nbCardOtherPlayer[0]=state.getNumCardsInHandsOfUpcomingPlayers()[0];
    		nbCardOtherPlayer[1]=state.getNumCardsInHandsOfUpcomingPlayers()[1];
    		nbCardOtherPlayer[2]=state.getNumCardsInHandsOfUpcomingPlayers()[2];
    	}
    	else //si il est inversé
    	{
    		nbCardOtherPlayer[0]=state.getNumCardsInHandsOfUpcomingPlayers()[2];
    		nbCardOtherPlayer[1]=state.getNumCardsInHandsOfUpcomingPlayers()[1];
    		nbCardOtherPlayer[2]=state.getNumCardsInHandsOfUpcomingPlayers()[0];
    	}
    	//
    	
    	//calcule de ce que le joueur a jouer:

    	//calcule du nombre de catre joué entre mon tour et mon tour précédent
    	int nbCardPlayed=(cardPlayedALL.size()-1)-(idLastCardIplay);
    	//
    	//calcule des cartes joués pendant le tour
    	List<Card> cardPlayedTour=new ArrayList<>();
    	for (int i=0;i<nbCardPlayed;i++)
    	{
    		cardPlayedTour.add(cardPlayedALL.get((cardPlayedALL.size()-1)-i));
    	}
    	cardPlayedTour=reverse(cardPlayedTour);

    	//calcule du nb de fois ou le joueur à passer son tour et la couleur qui y est associer
    	if (nbHavePlayed[0]<0)
    	{
    		int id=-1;
    		for (int j=0;j<4;j++)
    		{
    			if(upCard.getColor()==colorTabID[j])
    			{
    				id=j;
    			}
    		}
    		if(id!=-1)
    		{
    			nbHaveNotPlayed[0][id]++;
    		}
    	}
    	if (nbHavePlayed[1]<0)
    	{
    		int id=-1;
    		for (int j=0;j<4;j++)
    		{
    			if(upCard.getColor()==colorTabID[j])
    			{
    				id=j;
    			}
    		}
    		if(id!=-1)
    		{
    			nbHaveNotPlayed[1][id]++;
    		}
    	}
    	if (nbHavePlayed[2]<0)
    	{
    		int id=-1;
    		for (int j=0;j<4;j++)
    		{
    			if(upCard.getColor()==colorTabID[j])
    			{
    				id=j;
    			}
    		}
    		if(id!=-1)
    		{
    			nbHaveNotPlayed[2][id]++;
    		}
    	}
    	
    	//calcule de ce que chaques joueurs a jouer :
    	int idPlayer=0;  //le derrnier joueur à avoir jouer est le joueur 3
		int sens=1; //incrementation a l'envers
		if(lastSens==1) //si le jeu joue dans le sence inverse :
		{
			sens=-1; //incrementation du joueur a qui vas etre attribué la catre joué
			idPlayer=2; //le derrnier joueur à avoir jouer est le joueur 1
		}
		//si j'ai deja jouer et que la derriere carte joué est un skip on saute le joeuur après moi
		if (idLastCardIplay>0&&idLastCardIplay<cardPlayedALL.size()&&(cardPlayedALL.get(idLastCardIplay).getRank()==Rank.SKIP||cardPlayedALL.get(idLastCardIplay).getRank()==Rank.WILD_D4))
		{
			idPlayer+=sens;
	    	if (idPlayer>2)idPlayer=0;
	    	if (idPlayer<0)idPlayer=2;
		}
    	for (int i=0;i<nbCardPlayed;i++)
    	{
    		boolean isAssign=false;
    		int c=0; //evite les boucles infi si onarrive pas a attribue la carte
    		do
    		{
    			if (nbHavePlayed[idPlayer]>0||(nbHavePlayed[idPlayer]==0&&idLastCardIplay>0)) //si il a joué des cartes (0=pioche + joue)
	    		{
	    			assign(idPlayer,cardPlayedTour.get(i));
	    			isAssign=true;
	    			c=0;
	    		}
	    		else
	    		{
	    			c++;
	    			idPlayer+=sens;
		    		if (idPlayer>2)idPlayer=0;
		    		if (idPlayer<0)idPlayer=2;
	    		}

    		}while(!isAssign&&c<10);

    		if (cardPlayedTour.get(i).getRank()==Rank.REVERSE)
    		{
    			if (sens==-1) sens=1;
    			else sens=-1;
    		}
    		else if (cardPlayedTour.get(i).getRank()==Rank.SKIP||cardPlayedTour.get(i).getRank()==Rank.WILD_D4)
    		{
    			idPlayer+=sens;
	    		if (idPlayer>2)idPlayer=-1;
	    		if (idPlayer<0)idPlayer=3;
    		}
    		idPlayer+=sens;
		    if (idPlayer>2)idPlayer=0;
			if (idPlayer<0)idPlayer=2;
    	}

        // //affichage des cartes
        // System.out.println("\n\n");
        // System.out.print("Rosie:");
        // for (int i=0;i<cardPlayedJ1.size();i++)
        // {
        //     System.out.print(cardPlayedJ1.get(i).getRank()+" "+cardPlayedJ1.get(i).getColor()+" "+cardPlayedJ1.get(i).getNumber()+" / ");
        // }

        // System.out.println();
        // System.out.print("Robert:");
        // for (int i=0;i<cardPlayedJ2.size();i++)
        // {
        //     System.out.print(cardPlayedJ2.get(i).getRank()+" "+cardPlayedJ2.get(i).getColor()+" "+cardPlayedJ2.get(i).getNumber()+" / ");
        // }

        // System.out.println();
        // System.out.print("Garry:");
        // for (int i=0;i<cardPlayedJ3.size();i++)
        // {
        //     System.out.print(cardPlayedJ3.get(i).getRank()+" "+cardPlayedJ3.get(i).getColor()+" "+cardPlayedJ3.get(i).getNumber()+" / ");
        // }
        // System.out.println("\n\n");


    	//on determine si le joueur à une longe à carte
    	//ini
    	Color[] longe=new Color[3];
    	int[] puissanceLonge=new int[3];
    	int[] color=new int[4];
    	int colorDominante=-1;

    	//J1/////////////////////////////////
    	color[0]=0;
    	color[1]=0;
    	color[2]=0;
    	color[3]=0;
    	for (int i=0;i<cardPlayedJ1.size();i++)
    	{
    		switch (cardPlayedJ1.get(i).getColor())
    		{
    			case RED:
    				color[0]++;
    				break;
    			case GREEN:
    				color[1]++;
    				break;
    			case BLUE:
    				color[2]++;
    				break;
    			case YELLOW:
    				color[3]++;
    				break;
    		}
    	}
    	colorDominante=-1;
    	for (int i=0;i<4;i++)
    	{
    		if (color[i]>=2&&(colorDominante==-1||color[i]>color[colorDominante]))
    		{
    			colorDominante=i;
    		}
    	}
    	if(colorDominante!=-1) puissanceLonge[0]=color[colorDominante];
		switch (colorDominante)
		{
			case 0:
				longe[0]=Color.RED;
				break;
			case 1:
				longe[0]=Color.GREEN;
				break;
			case 2:
				longe[0]=Color.BLUE;
				break;
			case 3:
				longe[0]=Color.YELLOW;
				break;
		}
    	
		//J2/////////////////////////////////
    	color[0]=0;
    	color[1]=0;
    	color[2]=0;
    	color[3]=0;
    	for (int i=0;i<cardPlayedJ2.size();i++)
    	{
    		switch (cardPlayedJ2.get(i).getColor())
    		{
    			case RED:
    				color[0]++;
    				break;
    			case GREEN:
    				color[1]++;
    				break;
    			case BLUE:
    				color[2]++;
    				break;
    			case YELLOW:
    				color[3]++;
    				break;
    		}
    	}
    	colorDominante=-1;
    	for (int i=0;i<4;i++)
    	{
    		if (color[i]>=2&&(colorDominante==-1||color[i]>color[colorDominante]))
    		{
    			colorDominante=i;
    		}
    	}
    	if(colorDominante!=-1)puissanceLonge[1]=color[colorDominante];
		switch (colorDominante)
		{
			case 0:
				longe[1]=Color.RED;
				break;
			case 1:
				longe[1]=Color.GREEN;
				break;
			case 2:
				longe[1]=Color.BLUE;
				break;
			case 3:
				longe[1]=Color.YELLOW;
				break;
		}

    	//J3/////////////////////////////////
    	color[0]=0;
    	color[1]=0;
    	color[2]=0;
    	color[3]=0;
    	for (int i=0;i<cardPlayedJ3.size();i++)
    	{
    		switch (cardPlayedJ3.get(i).getColor())
    		{
    			case RED:
    				color[0]++;
    				break;
    			case GREEN:
    				color[1]++;
    				break;
    			case BLUE:
    				color[2]++;
    				break;
    			case YELLOW:
    				color[3]++;
    				break;
    		}
    	}
    	colorDominante=-1;
    	for (int i=0;i<4;i++)
    	{
    		if (color[i]>=2&&(colorDominante==-1||color[i]>color[colorDominante]))
    		{
    			colorDominante=i;
    		}
    	}
		if(colorDominante!=-1)puissanceLonge[2]=color[colorDominante];
		switch (colorDominante)
		{
			case 0:
				longe[2]=Color.RED;
				break;
			case 1:
				longe[2]=Color.GREEN;
				break;
			case 2:
				longe[2]=Color.BLUE;
				break;
			case 3:
				longe[2]=Color.YELLOW;
				break;
    	}
    	//calcule de ma longue:
    	Color colorMylonge=Color.RED;
    	Color chicaneColor=Color.RED;
    	Boolean iHaveLonge=false;
    	Boolean iHaveChic=false;
    	int[] tabColor=new int[4];
    	for (int i=0;i<hand.size();i++)
    	{
    		switch (hand.get(i).getColor())
    		{
    			case RED:
    				tabColor[0]++;
    				break;
    			case GREEN:
    				tabColor[1]++;
    				break;
    			case BLUE:
    				tabColor[2]++;
    				break;
    			case YELLOW:
    				tabColor[3]++;
    				break;
    		}
    	}
    	Color chicColor=Color.RED;
    	int colorMinNb=0;
    	for (int i=0;i<4;i++)
    	{
    		if(tabColor[i]<tabColor[colorMinNb]) colorMinNb=i;
    	}
    	if (tabColor[colorMinNb]<=1)
    	{
    		iHaveChic=true;
    		switch (colorMinNb)
			{
				case 0:
					chicColor=Color.RED;
					break;
				case 1:
					chicColor=Color.GREEN;
					break;
				case 2:
					chicColor=Color.BLUE;
					break;
				case 3:
					chicColor=Color.YELLOW;
					break;
	    	}
    	}



    	int coulDominate=-1;
    	for (int i=0;i<4;i++)
    	{
    		if (tabColor[i]>=2&&(coulDominate==-1||tabColor[i]>tabColor[coulDominate]))
    		{
    			coulDominate=i;
    		}
    	}
    	if (coulDominate!=-1) iHaveLonge=true;
    	switch (coulDominate)
		{
			case 0:
				colorMylonge=Color.RED;
				break;
			case 1:
				colorMylonge=Color.GREEN;
				break;
			case 2:
				colorMylonge=Color.BLUE;
				break;
			case 3:
				colorMylonge=Color.YELLOW;
				break;
    	}
    	if (cardPossible.size()>0)
    	{

	    	for (int i=0;i<cardPossible.size();i++)
	    	{
	    		Card carte=hand.get(cardPossible.get(i));
	    		//priorité des cartes
	    		if(carte.getRank()==Rank.NUMBER) //si un joueur vas gagner on se débarrase des cartes a forte valeur
	    		{
	    			priorityTap[i]+=carte.getNumber();
	    		}
	    		//si j'ai une longe : je joue en priorité les cartes dans cette couleur
	    		if(iHaveLonge&&carte.getColor()==colorMylonge)
	    		{
	    			priorityTap[i]+=10;
	    		}

	    		//si une longe à carte est detecté et que on peux jouer dans une autre couleur que cette longe on augmente la taux de jeu
	    		if(carte.getColor()!=longe[0]&&haveColor(carte))
	    		{
	    			priorityTap[i]+=10;
	    		}
	    		if(carte.getColor()!=longe[1]&&haveColor(carte))
	    		{
	    			priorityTap[i]+=10;
	    		}
	    		if(carte.getColor()!=longe[2]&&haveColor(carte))
	    		{
	    			priorityTap[i]+=10;
	    		}
	    		//si j'ai pas de cartes dans une couleur ou peu je doit garder les numero dans la couleur manquante qui n'ont pas été jhouer
	    		if(iHaveChic)
	    		{
	    			for (int j=0;j<cardPlayedALL.size();j++)
	    			{
	    				if(cardPlayedALL.get(j).getColor()==chicColor&&carte.getNumber()!=-1&&carte.getNumber()==cardPlayedALL.get(j).getNumber())
	    				{
	    					priorityTap[i]+=5;
	    				}
	    			}
	    		}
	    		//si un joueur passe son tour de magnière anormal = chicahne
	    		if(cardPlayedALL.size()>5&&!IsAJocker(carte))
	    		{
	    			for (int j=0;j<3;j++)
		    		{
		    			for (int k=0;k<4;k++)
		    			{
		    				if((float)nbHaveNotPlayed[j][k]==2) //si il passe plsu de 3 fois sons tour avec la meme couleur alors il a pas de carte dans cette couleur
			    			{
			    				if (carte.getColor()==colorTabID[k])
			    				{
			    					priorityTap[i]+=10;
			    				}
			    			}
							if((float)nbHaveNotPlayed[j][k]>2) //si il passe plsu de 3 fois sons tour avec la meme couleur alors il a pas de carte dans cette couleur
			    			{
			    				if (carte.getColor()==colorTabID[k])
			    				{
			    					priorityTap[i]+=15;
			    				}
			    			}
		    			}
		    		}
	    		}
	    		

	    		//si le joueur avant moi à bc de cartes:
	    		if (sensGame==0&&nbCardOtherPlayer[2]>6)
	    		{
	    			if (carte.getRank()==Rank.REVERSE)
	    			{
	    				priorityTap[i]+=20;
	    			}
	    		}
	    		else if(sensGame==1&&nbCardOtherPlayer[0]>6)
	    		{
	    			if (carte.getRank()==Rank.REVERSE)
	    			{
	    				priorityTap[i]+=20;
	    			}
	    		}
	    		//mise en difficulté du joueur qui vas gagner
	    		if (sensGame==0&&(vasGagner(nbCardOtherPlayer)[0]==0&&hand.size()-1>vasGagner(nbCardOtherPlayer)[1]))
	    		{
	    			if (carte.getRank()==Rank.WILD_D4)
	    			{
	    				priorityTap[i]+=30;
	    			}
	    			else if (IsNotNumberANotJocker(carte))
	    			{
	    				priorityTap[i]+=20;
	    			}
	    			if(carte.getColor()!=longe[0]) //si il a une longue elle est prioritaire sur les autres longes
		    		{
		    			priorityTap[i]+=10;
		    		}
	    		}
	    		else if (sensGame==1&&(vasGagner(nbCardOtherPlayer)[0]==2&&hand.size()-1>vasGagner(nbCardOtherPlayer)[1]))
	    		{
	    			if (carte.getRank()==Rank.WILD_D4)
	    			{
	    				priorityTap[i]+=30;
	    			}
	    			else if (IsNotNumberANotJocker(carte))
	    			{
	    				priorityTap[i]+=20;
	    			}
	    			if(carte.getColor()!=longe[2]) //si il a une longue elle est prioritaire sur les autres longes
		    		{
		    			priorityTap[i]+=10;
		    		}
	    		}

	    		//situation d'urgence : un joueur vas gagner !!!
	    		if (vasGagner(nbCardOtherPlayer)[1]<=3&&hand.size()>vasGagner(nbCardOtherPlayer)[1])
	    		{
	    			if(IsAJocker(carte)) //si un joueur vas gagner on se débarrase des cartes a forte valeur
		    		{
		    			priorityTap[i]+=50;
		    		}
		    		else if(IsNotNumberANotJocker(carte)&&(vasGagner(nbCardOtherPlayer)[1]<3&&hand.size()>vasGagner(nbCardOtherPlayer)[1])) //si un joueur vas gagner on se débarrase des cartes a forte valeur
		    		{
		    			priorityTap[i]+=20;
		    		}
		    		else if(carte.getRank()==Rank.NUMBER&&(vasGagner(nbCardOtherPlayer)[1]<3&&hand.size()>vasGagner(nbCardOtherPlayer)[1])) //si un joueur vas gagner on se débarrase des cartes a forte valeur
		    		{
		    			priorityTap[i]+=carte.getNumber()*2;
		    		}
	    		}
	    	}
	    	int posBiggestPriority=0;
	    	//on cherceh la carte avec la plus grand priorité de jeu
	    	for (int i=0;i<cardPossible.size();i++)
	    	{
	    		if (priorityTap[i]>priorityTap[posBiggestPriority])
	    		{
	    			posBiggestPriority=i;
	    		}
	    	}

	    	cardId=cardPossible.get(posBiggestPriority);

	    	idLastCardIplay=cardPlayedALL.size();

	    	//on memorise le sens du jeu en prenant en compte si je joue un reverse ou non
	    	lastSens=sensGame;
	    	if (hand.get(cardId).getRank()==Rank.REVERSE)
	    	{
	    		lastSens=(sensGame+1)%2;
	    	}
    	}

    	longuePlayeur[0]=longe[0];
    	longuePlayeur[1]=longe[1];
    	longuePlayeur[2]=longe[2];

    	return cardId;
    }


    public Color callColor(List<Card> hand) 
    {
    	Color[] colorTab={Color.RED,Color.GREEN,Color.BLUE,Color.YELLOW};
    	int[] priorityColor={0,0,0,0};

    	int[] ColorNb={0,0,0,0};
    	for (int i=0;i<4;i++)
    	{
    		for (int j=0;j<hand.size();j++)
    		{
    			if (hand.get(j).getColor()==colorTab[i])
    			{
    				ColorNb[i]++;
    			}
    		}
    	}

    	//maxnb
    	int maxColor=0;
    	int minColor=0;
    	for (int i=0;i<4;i++)
    	{
    		if (ColorNb[i]>ColorNb[maxColor])
    		{
    			maxColor=i;
    		}
    		if (ColorNb[i]<ColorNb[minColor])
    		{
    			minColor=i;
    		}
    	}


    	for (int i=0;i<4;i++)
    	{
    		if(colorTab[i]!=longuePlayeur[0])
			{
				priorityColor[i]+=10;
			}
			if(colorTab[i]!=longuePlayeur[1])
			{
				priorityColor[i]+=10;
			}
			if(colorTab[i]!=longuePlayeur[2])
			{
				priorityColor[i]+=10;
			}
			if(colorTab[i]==colorTab[maxColor])
			{
				priorityColor[i]+=15;
			}
			if(colorTab[i]!=colorTab[minColor])
			{
				priorityColor[i]+=15;
			}
    	}

    	Color selColor;
    	int maxPriority=0;
    	for (int i=0;i<4;i++)
    	{
    		if (priorityColor[i]>priorityColor[maxPriority])
    		{
    			maxPriority=i;
    		}
    	}
    	
        return colorTab[maxPriority];
    }

}
