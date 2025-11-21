/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_rush01.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: eamor-di <eamor-di@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/20 21:40:10 by eamor-di          #+#    #+#             */
/*   Updated: 2025/07/20 21:47:09 by eamor-di         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_RUSH01_H
# define FT_RUSH01_H
# include <stdlib.h>
# include <unistd.h>

int		count_visible(int *line);
void	fill_column(int **matrix, int col, int *colum_array);
void	reverse(int *src, int *dst);
int		check_views(int **matrix, int *views);
int		is_already_there(int **matrix, int row, int col, int num);
int		*views_array(char *str);
int		**malloc_matrix(void);
void	free_matrix(int **matrix);
void	print_matrix(int **matrix);
int		solve_game(int **matrix, int *views, int row, int col);
void	free_array(int *array);
void	write_string(char *str, int size);
#endif
